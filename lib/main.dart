//main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login.dart';
import 'user_SessionManager.dart';
import 'engine_helpers.dart';
import 'services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Workmanager().initialize(backgroundTaskCallback);

  FlutterNativeSplash.remove();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isGuest = false;

  ThemeMode _themeMode = ThemeMode.system;
  int _selectedIndex = 0;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void continueAsGuest() {
    setState(() {
      _isGuest = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, // Solange true bis final beta version
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          insetPadding: EdgeInsets.all(16),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),

      themeMode: _themeMode,

      home: AuthGate(
        onThemeChanged: changeTheme,
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        isGuest: _isGuest,
        onContinueAsGuest: continueAsGuest,
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  final bool isGuest;
  final VoidCallback onContinueAsGuest;
  final Function(ThemeMode) onThemeChanged;
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const AuthGate({
    super.key,
    required this.onThemeChanged,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.isGuest,
    required this.onContinueAsGuest,
  });

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _engineStarted = false;

  Future<void> _startEngine() async {
    FlutterNativeSplash.remove();
    final initFuture = UserSessionmanager.initialize();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingScreen(
        until: Future.wait([
          Future.delayed(const Duration(seconds: 2)),
          initFuture,
        ]),
      ),
    );

    await initFuture;
    final runner = await EngineRunner.create();
    runner.startWatching();
    EngineHelpers();
    runEngine();

    await Workmanager().registerPeriodicTask(
      "achievementEngineTask",
      "checkAchievements",
      frequency: Duration(minutes: 30),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    print('[WorkManager] Background-Task registriert');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (widget.isGuest) {
          return GoogleBottomBar(
            onThemeChanged: widget.onThemeChanged,
            initalIndex: widget.selectedIndex,
            onIndexChanged: widget.onIndexChanged,
          );
        }

        if (session == null) {
          _engineStarted = false;
          return SignInPage2(onContinueAsGuest: widget.onContinueAsGuest);
        }

        if (!_engineStarted) {
          _engineStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startEngine();
          });
        }

        return GoogleBottomBar(
          onThemeChanged: widget.onThemeChanged,
          initalIndex: widget.selectedIndex,
          onIndexChanged: widget.onIndexChanged,
        );
      },
    );
  }
}

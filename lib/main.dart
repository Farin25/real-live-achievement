//main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login.dart';
import 'user_SessionManager.dart';
import 'engine_helpers.dart';
import 'services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
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
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
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
    await UserSessionmanager.initialize();
    final runner = await EngineRunner.create();
    runner.startWatching();
    EngineHelpers();
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
          _startEngine();
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

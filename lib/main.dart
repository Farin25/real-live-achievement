//main.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'user_sessionmanager.dart';
import 'engine_helpers.dart';
import 'services.dart';
import 'package:workmanager/workmanager.dart';
import 'settings.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    int errorcode = 201;
    runApp(ConfigFail(errorcode: errorcode));
    return;
  }
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    if (kDebugMode) print('[supabase] Init failed code: 203');
    dLog('[supabase] Init failed code: 203: $e');
    runApp(ConfigFail(errorcode: 203));
    return;
  }

  try {
    await Workmanager().initialize(backgroundTaskCallback);
  } catch (e) {
    dLog('[Workmanager] Init failed code: 204: $e');
    startupErrors.add('Error 204: fehler beim Starten des Backgroundtask.');
  }
  try {
    await AppServices.initializeNotifications();
  } catch (e) {
    dLog('[Notifications] Init failed Code: 205: $e');
    startupErrors.add(
      'Error 205: Fehler beim Starten des Notificationservice.',
    );
  }

  final sentryEnabled = await SettingsService.loadBool('sentryEnabled', false);

  await SentryFlutter.init((options) {
    options.dsn =
        'https://718222f375e2a2fde953dfa3a68575c4@o4511530251255808.ingest.de.sentry.io/4511530257350736';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = sentryEnabled ? 0.2 : 0.0;
    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    // options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(SentryWidget(child: const MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

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

  Future<void> _loadTheme() async {
    final saved = await SettingsService.loadString('currentThemeMode', 'dark');
    final mode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        canvasColor: AppColors.lightBackground,

        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.lightCard,
              surfaceContainerHighest: AppColors.lightElevated,
              onSurface: AppColors.lightForeground,
              outline: AppColors.border,
            ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightForeground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        dividerTheme: DividerThemeData(
          color: Colors.black.withValues(alpha: 0.08),
          thickness: 1,
          space: 1,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),

        iconTheme: const IconThemeData(color: AppColors.lightForeground),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.border),
          ),
        ),

        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,

        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.card,
              surfaceContainerHighest: AppColors.elevated,
              onSurface: AppColors.foreground,
              outline: AppColors.border,
            ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.08),
          thickness: 1,
          space: 1,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),

        iconTheme: const IconThemeData(color: AppColors.foreground),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.border),
          ),
        ),

        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),

      themeMode: _themeMode,

      home: SplashWrapper(
        child: AuthGate(
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
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _engineStarted = false;

  Future<bool> _deletionStatus() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final deleteprofile = await supabase
          .from('profiles')
          .select('deleted_at, deletion_scheduled_for')
          .eq('id', user.id)
          .maybeSingle();

      if (deleteprofile == null) return false;
      if (deleteprofile['deleted_at'] == null) {
        return false;
      }
      final deletedAt = deleteprofile['deleted_at'].toString();
      final deletedSchedule =
          deleteprofile['deletion_scheduled_for']?.toString() ?? 'unbekannt';

      if (!mounted) return true;

      final stateContext = context;
      await showDialog(
        context: stateContext,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text('Dein Account wurde am $deletedAt gelöscht'),
          content: Text(
            'Wird am $deletedSchedule vollständig gelöscht. Wiederherstellen?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await supabase.auth.signOut();
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.rpc('reactivate_user_account', params: {});
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await supabase.auth.signOut();
                showAppSnackBar('Wiederhergestellt! Bitte neu einloggen.');
              },
              child: const Text('Wiederherstellen'),
            ),
          ],
        ),
      );
      return true;
    } on SocketException {
      if (kDebugMode) {
        print('Keine Internet Verbindung');
      }
      return false;
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return false;
    }
  }

  Future<void> _startEngine() async {
    if (await _deletionStatus()) return;

    final initFuture = UserSessionmanager.initialize();

    await showDialog(
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
    try {
      await Workmanager().registerPeriodicTask(
        "achievementEngineTask",
        "checkAchievements",
        frequency: Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      dLog('[WorkManager] Background-Task registriert');
    } catch (e, stack) {
      await Sentry.captureException(e, stackTrace: stack);
      showAppSnackBar('BG Task Initialization Failed, Code: 202');
    }
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
          //TODO Loadingstate cleaner machen
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

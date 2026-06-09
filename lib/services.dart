//Services.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:real_live_achievments/achievments.dart';
import 'package:real_live_achievments/home.dart';
import 'package:real_live_achievments/settings.dart';
import 'package:real_live_achievments/social.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class AppConfig {
  static const String appname = "AchieveIRL";
  static const String version = "BETA 0.5(dev)";
  static const String website = "https://www.achieveirl.de";
}

class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const card = Color(0xFF111118);
  static const elevated = Color(0xFF16161F);
  static const foreground = Color(0xFFF0F0F5);

  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const accent = Color(0xFF10B981);

  static Color get border => primary.withValues(alpha: 0.20);
  static Color get borderHover => primary.withValues(alpha: 0.40);
  static const textMuted = Color(0xFF9CA3AF);
  static const textSubtle = Color(0xFF6B7280);

  static const catTravel = Color(0xFFFB923C);
  static const catFitness = Color(0xFFF472B6);
  static const catNature = Color(0xFF4ADE80);
  static const catFun = Color(0xFFF87171);
  static const catApp = Color(0xFF60A5FA);
  static const catEvents = Color(0xFFFACC15);

  // Light Mode
  static const lightBackground = Color(0xFFF8F9FB);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFF0F0F5);
  static const lightForeground = Color(0xFF0A0A0F);
  static const lightTextMuted = Color(0xFF4B5563);
  static const lightTextSubtle = Color(0xFF9CA3AF);

  static Color bg(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? background : lightBackground;
  static Color cardC(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? card : lightCard;
  static Color elev(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? elevated : lightElevated;
  static Color fg(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? foreground : lightForeground;
  static Color muted(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? textMuted : lightTextMuted;
  static Color subtle(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? textSubtle : lightTextSubtle;
}

void dLog(String message) {
  if (kDebugMode) print(message);
}

class AppServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  //--------------------------------------------
  //----------Local Notifications init----------
  //--------------------------------------------
  static Future<void> initializeNotifications() async {
    if (_isInitialized) return;

    await Permission.notification.request();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('icon'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    dLog('Notifications initialized');
  }

  //--------------------------------------------
  //----------Push Achievement Notification-----
  //--------------------------------------------
  static Future<void> pushAchievementNotification({
    required String achievementId,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    await _notificationsPlugin.show(
      id: achievementId.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements Freigeschaltet',
          channelDescription: 'Achievement Benachrichtigungen',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  //--------------------------------------------
  //----------Notification Tap Handler----------
  //--------------------------------------------
  static void _onNotificationTapped(NotificationResponse response) {
    dLog('Notification tapped: ${response.payload}');
  }
}

//---------------------------
//-----------Cache-----------
//---------------------------

class UserLocalServices {
  static Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String birthdate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('first_name', firstName);
    await prefs.setString('last_name', lastName);
    await prefs.setString('username', username);
    await prefs.setString('birthdate', birthdate);
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('username');
    await prefs.remove('birthdate');
  }
}

//------------------------------
//-----------Loadingscreen------
//------------------------------
class LoadingScreen extends StatefulWidget {
  final Duration? duration;
  final Future? until;

  const LoadingScreen({super.key, this.duration, this.until});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _funfact = 'Funfacts werden geladen..';
  final supabase = Supabase.instance.client;
  Timer? _funfactTimer;

  @override
  void initState() {
    super.initState();
    _loadfunction();

    _funfactTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadfunction();
    });

    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) Navigator.pop(context);
      });
    }

    if (widget.until != null) {
      widget.until!.then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _funfactTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadfunction() async {
    if (!mounted) return;

    final funfacts = await supabase
        .from('loading_funfacts')
        .select('id, funfact');

    if (!mounted) return;

    if (funfacts.isEmpty) return;
    final random = Random();
    final rndomIndex = random.nextInt(funfacts.length);
    final funfact = funfacts[rndomIndex]['funfact'];

    setState(() {
      _funfact = funfact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.fg(context)),
            const SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: AppColors.fg(context))),
            const SizedBox(height: 24),
            Text(_funfact, style: TextStyle(color: AppColors.muted(context))),
          ],
        ),
      ),
    );
  }
}

//---------------------------------------
//-----------SplashWrapper---------------
//---------------------------------------
class SplashWrapper extends StatefulWidget {
  final Widget child;

  const SplashWrapper({super.key, required this.child});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return LoadingScreen(duration: null, until: null);
    }
    return widget.child;
  }
}

//----------------------------
//-----------navbar-----------
//----------------------------
class GoogleBottomBar extends StatefulWidget {
  final int initalIndex;
  final Function(ThemeMode) onThemeChanged;
  final Function(int) onIndexChanged;

  const GoogleBottomBar({
    super.key,
    required this.onThemeChanged,
    required this.initalIndex,
    required this.onIndexChanged,
  });

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initalIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      NewsFeedPage1(),
      AchievmentSeite(),
      Socialsite(),
      SettingsPage(onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtle(context),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onIndexChanged(index);
        },
        items: _navBarItems,
      ),
    );
  }
}

final _navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: const Text("Home"),
    selectedColor: AppColors.primary,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.emoji_events),
    title: const Text("Achievements"),
    selectedColor: AppColors.primary,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.people),
    title: const Text("Social"),
    selectedColor: AppColors.primary,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.settings),
    title: const Text("Settings"),
    selectedColor: AppColors.primary,
  ),
];
//----------------------------
//---------Snackbar-----------
//----------------------------

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      content: _AppSnackBarContent(message: message, isDark: isDark),
    ),
  );
}

class _AppSnackBarContent extends StatelessWidget {
  final String message;
  final bool isDark;

  const _AppSnackBarContent({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.elevated, AppColors.card]
              : [AppColors.lightCard, AppColors.lightElevated],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.10),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 0,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  'assets/icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.notifications_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            width: 1,
            height: 28,
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
          const SizedBox(width: 12),

          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: isDark
                    ? AppColors.foreground
                    : AppColors.lightForeground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//-------------------------------------------
//----------Loading screen -- Wolke----------
//-------------------------------------------
class LoadingScreenWolke extends StatefulWidget {
  final Duration? duration;
  final Future? until;

  const LoadingScreenWolke({super.key, this.duration, this.until});

  @override
  State<LoadingScreenWolke> createState() => _LoadingScreenWolkeState();
}

class _LoadingScreenWolkeState extends State<LoadingScreenWolke> {
  int _frame = 0;
  Timer? _timer;

  static const List<String> frames = [
    'assets/loading_1.png',
    'assets/loading_2.png',
    'assets/loading_3.png',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _frame = (_frame + 1) % frames.length;
      });
    });

    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) Navigator.pop(context);
      });
    }

    if (widget.until != null) {
      widget.until!.then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(frames[_frame]),
            const SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: AppColors.fg(context))),
          ],
        ),
      ),
    );
  }
}

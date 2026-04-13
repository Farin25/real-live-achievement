//Services.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:real_live_achievments/achievments.dart';
import 'package:real_live_achievments/home.dart';
import 'package:real_live_achievments/settings.dart';
import 'package:real_live_achievments/social.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'dart:async';

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

  // Cache Löschen
  static Future<void> clearAchievementCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('cached_achievements');
    //Debug Ausgabe
    print("Achievement Cache gelöscht");
  }
}

//----------------------------------
//----------Loading screen----------
//----------------------------------

class LoadingScreen extends StatefulWidget {
  final Duration? duration;
  final Future? until;

  const LoadingScreen({super.key, this.duration, this.until});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _frame = 0;
  Timer? _timer;

  final List<String> frames = [
    'assets/loading_1.png',
    'assets/loading_2.png',
    'assets/loading_3.png',
  ];

  @override
  void initState() {
    super.initState();

    // Timer und fram rate
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _frame = (_frame + 1) % frames.length;
      });
    });

    // die feste dauer
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) Navigator.pop(context);
      });
    }
    // Warten bis fertig
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
      backgroundColor: Colors.black,
      body: Center(child: Image.asset(frames[_frame])),
    );
  }
}

//----------------------------------
//----------Vimeo Viedeo------------
//----------------------------------

class VimeoVideo extends StatefulWidget {
  const VimeoVideo({super.key});

  @override
  State<VimeoVideo> createState() => _VimeoVideoState();
}

// Lädt Vimeo Viedeo im iframe
class _VimeoVideoState extends State<VimeoVideo> {
  WebViewController? controller;
  bool _accepted = false;

  void _loadVideo() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <html>
          <body style="margin:0; background:black;">
            <iframe 
              src="https://player.vimeo.com/video/1167330665"
              width="100%" 
              height="100%" 
              frameborder="0"
              allow="autoplay; fullscreen"
              allowfullscreen>
            </iframe>
          </body>
        </html>
      ''');

    setState(() {
      _accepted = true;
    });
  }

  @override // DSGVO Boutton
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _accepted
          ? WebViewWidget(controller: controller!)
          : Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 80,
                    color: Colors.white70,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        const Text(
                          "Externer Inhalt von Vimeo\nDurch Klick wird eine Verbindung zu Vimeo hergestellt.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadVideo,
                          child: const Text("Video laden"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
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

  Widget build(BuildContext context) {
    final pages = [
      NewsFeedPage1(),
      AchievmentSeite(),
      Socialsite(),
      SettingsPage(onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      // appBar: AppBar(title: const Text('Google Bottom Bar')), // Auskomentiert Weil app bar ist auf jeder seite festgelegt
      body: pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
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
    selectedColor: Colors.purple,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.emoji_events),
    title: const Text("Achievments"),
    selectedColor: Colors.pink,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.people),
    title: const Text("Social"),
    selectedColor: Colors.orange,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.settings),
    title: const Text("Settings"),
    selectedColor: Colors.teal,
  ),
];

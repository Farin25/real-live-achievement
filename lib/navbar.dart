import 'package:flutter/material.dart';
import 'package:real_live_achievments/achievments.dart';
import 'package:real_live_achievments/home.dart';
import 'package:real_live_achievments/settings.dart';
import 'package:real_live_achievments/social.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';




class GoogleBottomBar extends StatefulWidget {
  const GoogleBottomBar({super.key});

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    NewsFeedPage1 (),
    AchievmentSeite(),
    Socialsite(),
    SettingsPage(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: AppBar(title: const Text('Google Bottom Bar')), // Auskomentiert Weil app bar ist auf jeder seite festgelegt
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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

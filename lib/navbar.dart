import 'package:flutter/material.dart';
import 'package:real_live_achievments/achievments.dart';
import 'package:real_live_achievments/acount.dart';
import 'package:real_live_achievments/social.dart';
import 'dart:ui';
import 'home.dart';
import 'social.dart';
import 'settings.dart';

class Navbar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container (
      padding: EdgeInsets.only(bottom: 0),
      child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white.withOpacity(0.1),
      elevation: 0,
      selectedItemColor: Theme.of(context).primaryColor,    
      unselectedItemColor: Theme.of(context).iconTheme.color?.withOpacity(0.6),
      onTap: (index) {

        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        }

         else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AchievmentSeite()));
        }

        else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Socialsite()));
        }

         else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
        }


      },
      items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: '',
      ),
    ],
    ),
    );
  }
}
import 'package:flutter/material.dart';
import 'navbar.dart';

class acountsite extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acount'),
      ),
      body: Center(
        child: Text('Hier kannst du deinen Acount verwalten und einstellungen Setzen',
        style: TextStyle(fontSize: 20),
      ),
     ),
     bottomNavigationBar: Navbar(),
    );
  }
}
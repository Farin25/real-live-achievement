import 'package:flutter/material.dart';
import 'navbar.dart';

class Socialsite extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social'),
      ),
      body: Center(
        child: Text('Das Wird Später die Social Seite /n Damit du Dich mit Frunden Ranken kannst musst du Cloud Sync ind en Einstellungen Aktivieren',
        style: TextStyle(fontSize: 20),
      ),
     ),
     bottomNavigationBar: Navbar(),
    );
  }
}
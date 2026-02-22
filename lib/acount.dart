import 'package:flutter/material.dart';
import 'navbar.dart';

class AcountPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acount'),
      ),
      body: Center(
        child: Text('Hier kommen die Acount Settings hin also hier kanhnsrt du dann so sachen wie username usw einstellen',
        style: TextStyle(fontSize: 20),
      ),
     ),
    // bottomNavigationBar: Navbar(),
    );
  }
}
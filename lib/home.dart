import 'package:flutter/material.dart';
import 'navbar.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'),
      ),
      body: Center(
        child: Text('Das Wird Später die HomeSeite',
        style: TextStyle(fontSize: 20),
      ),
     ),
     bottomNavigationBar: Navbar(),
    );
  }
}
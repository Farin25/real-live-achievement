//social.dart
import 'package:flutter/material.dart';

class Socialsite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social')),
      body: Center(
        child: Text(
          'Hier entsteht der Social Bereich.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

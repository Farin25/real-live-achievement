import 'package:flutter/material.dart';


class AchievmentSeite extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievments'),
      ),
      body: Center(
        child: Text('Hier Entsteht die Achievments Seite.......',
        style: TextStyle(fontSize: 20),
      ),
     ),
   //  bottomNavigationBar: Navbar(),
    );
  }
}
import 'package:flutter/material.dart';
import 'navbar.dart';
import 'licenses.dart';
import 'about.dart';
import 'acount.dart';


class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => AcountPage()));
              },
           //Der Profiel Bereich Wichtig und richtig
           child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                ),
              child: Row(
                children: [
                  // Profiel Icon Auch sehr wichtig
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  SizedBox(width: 16,),
                  // Fast am Wichtigsten der NAme und der USername
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      'Gaming2easy',// Nutzername später aus DB
                      style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Leon Pappendorf', // Richtiger name Später AUS db
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
            SizedBox(height: 30),
            Divider(),
            //Die Settings
            Expanded(
              child: ListView(
                children: [
                  //Settings für Dark mode/white mode
                  ListTile(
                    leading: Icon(Icons.brightness_6),
                    title: Text("Design"),
                    subtitle: Text("Dark Mode, Light Mode"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AcountPage()));
                
                    },
                  ),
                  Divider(),

                  // Sprach Settings
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text("Sprache"),
                    subtitle: Text("Deutch DE"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sprachen kommen bald')),
                
                      );
                    },
                   ),
                   Divider(),
                   //About Seite
                   ListTile(
                    leading: Icon(Icons.info),
                    title: Text("info"),
                    subtitle: Text("über die App"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                   ),
                   Divider(),

                   //Lizenzen

                   ListTile(
                    leading: Icon(Icons.description),
                    title: Text("Open Source Lizenzen"),
                    subtitle: Text("Verwendete Bibiotheken und Software"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LicensesPage()));
                    },
                   ),   
                ],
              ),
            ),
          ], 
        ),
      ),
      //bottomNavigationBar: Navbar(),
    );
  }
}
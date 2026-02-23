import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';
import 'variabels.dart';
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Über die App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(//Icon
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // App Name
            Center(
              child: Text(
                AppConfig.appname,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            
            // Version
            Center(
              child: Text(
                AppConfig.version,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // Beschreibung
            Text(
              'Über die App:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Real Live Achievements motiviert dich, echte Ziele im Leben zu erreichen! '
              'Sammle Achievements im Echten Leben! '
              'Teile deine Erfolge mit Freunden und lass dich von ihren Achievements inspirieren.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            
 
            
            // Developer
            Text(
              'Entwickler / Herausgeber:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black),
                  children: [
             TextSpan(
              text: 'Farin Langner',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                      ..onTap = () async {
            
                        final Uri url = Uri.parse('https://farin-langner.de');
                        await launchUrl(url, mode: LaunchMode.platformDefault);

                       
          
                      },
            ),
                  
                    TextSpan(
                      text: ' & ',
                      style: TextStyle(
                         color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                      ),
                    TextSpan(
                      text: 'Liam Selent',
                      style: TextStyle(
                         color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              Text(
                'Rechtliches & Links:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              linkTile('Webseite', 'https://farin25.github.io/real-live-achievement/'),
              linkTile('Impressum', 'https://farin-langner.de/impressum'),
              linkTile('Datenschutzerklärung', 'https://farin-langner.de/datenschutz'),

              SizedBox(height: 30),
              Text(
              '© 2025-2026 Farin Langner & Liam Selent Alle Rechte Vorbehalten',
              style: TextStyle(
                fontSize: 14,
                 color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              ),
              
            ),
            
            
          ],
        ),
      ),
   //   bottomNavigationBar: Navbar(),
    );
  }
}

Widget linkTile(String title, String url) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    ),
    onTap: () async {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    },
  );
}
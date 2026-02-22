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
      body: Padding(
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
              'Entwickler:',
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
              '© 2025-2026 Real Live Achievements',
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

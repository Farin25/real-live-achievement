import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'variabels.dart';
import 'addins.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
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
                decoration: BoxDecoration( // Lädt Icon
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
              'Up Mark motiviert dich, echte Ziele im Leben zu erreichen! '
              'Sammle Achievements im Echten Leben! '
              'Teile deine Erfolge mit Freunden und lass dich von ihren Achievements inspirieren.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            //Lädt das Viedeo aus der VimeoVideo Klasse
            VimeoVideo(),

            SizedBox(height: 30),


              Text(
                'Links:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              linkTile('Webseite', 'https://farin25.github.io/real-live-achievement/'),
              linkTile('Eigenes Achievment Einreichen', 'https://farin25.github.io/real-live-achievement/docs/Dein_Achievment/'),
              linkTile('Newsletter', 'https://farin25.github.io/real-live-achievement/docs/newsletter'),
              linkTile('SourceCode', 'https://github.com/Farin25/real-live-achievement'),
              linkTile('Changelog', 'https://farin25.github.io/real-live-achievement/docs/Changelog'),
        
              SizedBox(height: 10),

              Text(
                'Rechtliches:',      
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              linkTile('Impressum', 'https://farin25.github.io/real-live-achievement/docs/Rechtliches/impressum/'),
              linkTile('Datenschutzerklärung', 'https://github.com/Farin25/real-live-achievement'),
              linkTile('Algemeine Gschäfts Bedingungen', 'http://localhost:3000/real-live-achievement/docs/Rechtliches/agb'),
              linkTile('FAQ', 'https://farin25.github.io/real-live-achievement/docs/FAQ'),

              //MAil
              linkTile(
                'Support kontaktieren oder Fehler melden',
                'mailto:Achievments@holzideen.org?subject=Support%20RealLiveAchievement&body=Hallo,%0A%0Aich%20habe%20folgendes%20Problem:%0A',
              ),


              SizedBox(height: 10),

                  Text(
              'Dankesagung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            RichText(text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: 'Ein großer dank geht an alle tester der Beta Version und an alle Lehrer*innen die an uns Geglaubt haben und es ermöglich haben dieses Projekt im rahmen den Projekt orientiertes lernen zu machen. Wir bedanken uns auch bei allen die Eine Idee für ein Acheievment Eingereicht haben un und Feedback zur App gegeben haben. ',
                ),
              ],
            )),

            SizedBox(height: 20),

     
            Text(
              'Entwickler / Herausgeber:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
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


              SizedBox(height: 30), // Footer mit Abstand 30px
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
   //   bottomNavigationBar: Navbar(), Auskommentiert weil noch nicht sicher ob nav bar aj oder nein
    );
    
  }
}


Widget linkTile(String title, String url) { // Design der Links wird oben aufgerufen
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
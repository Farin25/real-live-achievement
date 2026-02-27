import 'package:flutter/material.dart'; // Import dfer flutter Bibilothek die grundbausteine wie scaffold usw enthält und essenziel ist 
import 'package:supabase_flutter/supabase_flutter.dart'; // Import der Subase Libary für die Komunikation mit Subase
import 'package:flutter_dotenv/flutter_dotenv.dart'; //import dotenv libary für die env datei für secretts weil flutter/dart das in vanilla nicht kann
import 'login.dart'; // import der login.dart damit das Authgate weiß wo es hinleiten muss
import 'navbar.dart'; // Import der Datei wo die nav bar also die NAvigationsleite ist damit sie eingebunden werden kann
/*    TODO Username Prüfung !Wichtig!
*/

Future<void> main() async { //main funktion wird immer als erstes ausgeführt
  WidgetsFlutterBinding.ensureInitialized(); // verbindung zwischen framework flutetr und der engine flutter sozusagen die Brücke zwischen der hardware und der app

  await dotenv.load(fileName: ".env"); // Läsdt die .env Datei mit den Schlüßeln usews für die verbindung zum Backend

  await Supabase.initialize( //Verbindung der app mit dem Backend bei Supbase
    url: dotenv.env['SUPABASE_URL']!, // Die Subase URL aus der .env wird heir geladen
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,// Hier wird der Subase Public_key geladen auch asu der.env
  );

  runApp(const MyApp()); // Startet die klasse MY app 
}

class MyApp extends StatelessWidget { // NEue Klasse name: MyApp las ein statless widget
  const MyApp({super.key}); // Leitet das an das Widget weiter

  @override //Überschreibt das Widget Design
  Widget build(BuildContext context) { // baut das Widget im eigenen design wie unten angegeben 
    return MaterialApp( //Eine art Herzstück gibt es nur einmal
      debugShowCheckedModeBanner: false, // Debug banner oben rechts also ob false = nicht anzeifgen oder halt true = anzeigen
      theme: ThemeData( //Das Deisgn so ähnlich wie css
      useMaterial3: true, // Aktiviert das Mdoerne Design material 3 Nutzt eine Frabpaltettte von 28 Vaerschiedenen Farbtännen die alle aus der grundfarbe untenfestgelegt generiret werden
        colorScheme: ColorScheme.fromSeed( // grundfarbe 
          seedColor: Colors.blue,// Blau
          brightness: Brightness.light, // helll
        ),// Helles Blau als Grundfarbe
      ),
      darkTheme: ThemeData( // Dark Mode
        colorScheme: ColorScheme.fromSeed( //Wider die grundfarbe
          seedColor: Colors.blue,//Wieder blau
          brightness: Brightness.dark, // Diesmal aber Dunkel
        ),
      ),// Dark mode blau dunkel
      home: AuthGate(), //Startet das Auth Gate

    );
    
    
  }

  
  
}


class AuthGate extends StatelessWidget { //Klasse Auth Gate als Statless widget also auch wieder statisch
  const AuthGate({super.key}); // GIbt wider an das widget weiter

  @override // Wieder das eigene Design
  Widget build(BuildContext context) { // Baut dAs widget nach  den untesnstehenden design
    return StreamBuilder<AuthState>( //Beobachtet den Login Zustand des USeres und wenn sich was ändert wird das Widget neu gebaut
      stream: Supabase.instance.client.auth.onAuthStateChange, // Der bobachtete Zusatand
      builder: (context, snapshot) {  //Wennd er Stream oben einen neuen zustand schikt wird hier neugebaut bzw. aufgerufen

        final session = snapshot.data?.session; // Hier wird das was der stream schikt entschlüßelt. Das ? Zeichen ist null Staftey also wenn nichts zurückgegeben wird wird einfach aufg null gesetzt

        if (session == null) { // Wenn nichts zurückgegeben wird halt null
          return const SignInPage2(); // Dann Gehe zur SingInPage 2 
        }

        return FutureBuilder( // wrnn nicht null entpackt wird
          future: _ensureProfileExists(session.user), // Prüft ob es den user schon in der eigenen profieles tabelle in der DB gibt. Ruft dafür die Funktion unten auf
          builder: (context, profileSnapshot) { //Fragt den DB (Datenbank) Status ab 

            if (profileSnapshot.connectionState == ConnectionState.waiting) {// Wennd er Status warten ist also die DB arbeitet noch
              return const Scaffold( // Erstellt einen scaffold also ein grundgerüst
                body: Center(child: CircularProgressIndicator()), // Erstellt in dem Grundgerüst (Scaffold) einen Runden Ladebalken
              );
            }

            return const GoogleBottomBar(); //Wenn die Antwort der Db kommt setze die Navbar ein also die Navigationsleiste unten
          },
        );
      },
    );
  }

  Future<void> _ensureProfileExists(User user) async { // die oben aufgerufene Funktion 
    final supabase = Supabase.instance.client;

    final existing = await supabase //erstellt eine locale variablen mit den namen Subase mitd en unten definierten sachen 
        .from('profiles') //asu der Tabelle Profieles
        .select('id') //Die id aus der Profieles
        .eq('id', user.id) // die user id
        .maybeSingle(); // auch eine null saftey regel wenn nichts zurückommt dann gib null zurück

    if (existing == null) { //wenn null zurückegheben wir aus unserer zero safty regel oben
      await supabase.from('profiles').insert({ // warte bis das ergebniss da ist  und dann trage in en Profieles Datatabel in der DB ein
        'id': user.id, // USER ID
        'first_name': user.userMetadata?['first_name'],// Nmae
        'last_name': user.userMetadata?['last_name'],//  nachnahme
        'username': user.userMetadata?['username'], //Username
        'birthdate': user.userMetadata?['birthdate'], // Geburstadtaum 
      });// Trägt alles obenstehende aus der Subase Variabel in die DB ein wenn es dort noch nicht exestiert
    }
  }
}


//ENDE
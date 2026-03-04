import 'package:flutter/material.dart'; // Import dfer flutter Bibilothek die grundbausteine wie scaffold usw enthält und essenziel ist 
import 'package:supabase_flutter/supabase_flutter.dart'; // Import der Subase Libary für die Komunikation mit Subase
import 'package:flutter_dotenv/flutter_dotenv.dart'; //import dotenv libary für die env datei für secretts weil flutter/dart das in vanilla nicht kann
import 'login.dart'; // import der login.dart damit das Authgate weiß wo es hinleiten muss
import 'navbar.dart'; // Import der Datei wo die nav bar also die NAvigationsleite ist damit sie eingebunden werden kann
import 'user_SessionManager.dart';

Future<void> main() async { //main funktion wird immer als erstes ausgeführt
  WidgetsFlutterBinding.ensureInitialized(); // verbindung zwischen framework flutetr und der engine flutter sozusagen die Brücke zwischen der hardware und der app

  await dotenv.load(fileName: ".env"); // Läsdt die .env Datei mit den Schlüßeln usews für die verbindung zum Backend

  await Supabase.initialize( //Verbindung der app mit dem Backend bei Supbase
    url: dotenv.env['SUPABASE_URL']!, // Die Subase URL aus der .env wird heir geladen
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,// Hier wird der Subase Public_key geladen auch asu der.env
  );

  runApp(const MyApp()); // Startet die klasse MY app 
}

class MyApp extends StatefulWidget { // NEue Klasse name: MyApp las ein statless widget
  const MyApp({super.key}); // Leitet das an das Widget weiter

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  bool _isGuest = false;
  

  ThemeMode _themeMode = ThemeMode.system;
  int _selectedIndex = 0;
  

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });

    }

      void continueAsGuest() {
      setState(() {
        _isGuest = true;
      });
    }

  @override //Überschreibt das Widget Design
  Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: true,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    ),
    darkTheme: ThemeData( // Hier wurde die Struktur korrigiert
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ),
    

      themeMode: _themeMode,

      home: AuthGate(onThemeChanged: changeTheme,
      selectedIndex: _selectedIndex,
      onIndexChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      isGuest: _isGuest,
      onContinueAsGuest: continueAsGuest,
      ),

    );

  }
  

}

class AuthGate extends StatelessWidget { 
   // GAst bzw. Localer Acount
   final bool isGuest;
   final VoidCallback onContinueAsGuest;
   // Dark / light mode
   final Function(ThemeMode) onThemeChanged;
   // nav bar asugewählte seite
   final int selectedIndex;
   final Function(int) onIndexChanged;


   const AuthGate({super.key,
   required this.onThemeChanged,
   required this.selectedIndex,
   required this.onIndexChanged,
   required this.isGuest,
   required this.onContinueAsGuest
   }); 

   

  @override 
  Widget build(BuildContext context) { 
    return StreamBuilder<AuthState>( 
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) { 

        final session = snapshot.data?.session; 

        if (isGuest) {
          return GoogleBottomBar(
            onThemeChanged: onThemeChanged,
            initalIndex: selectedIndex,
            onIndexChanged: onIndexChanged,
          );
        }

        if (session == null) {
          return SignInPage2(
          onContinueAsGuest: onContinueAsGuest);
        }

        UserSessionmanager.initialize();

        return GoogleBottomBar(onThemeChanged: onThemeChanged, initalIndex: selectedIndex, onIndexChanged: onIndexChanged);

       
        
      }
     );
  }

}


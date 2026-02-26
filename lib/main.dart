import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login.dart';
import 'navbar.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: AuthGate(),
      
    );
    
    
  }

  
  
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {

        final session = snapshot.data?.session;

        if (session == null) {
          return const SignInPage2();
        }

        return FutureBuilder(
          future: _ensureProfileExists(session.user),
          builder: (context, profileSnapshot) {

            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return const GoogleBottomBar();
          },
        );
      },
    );
  }

  Future<void> _ensureProfileExists(User user) async {
    final supabase = Supabase.instance.client;

    final existing = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) { 
      await supabase.from('profiles').insert({
        'id': user.id,
        'first_name': user.userMetadata?['first_name'],
        'last_name': user.userMetadata?['last_name'],
        'username': user.userMetadata?['username'],
        'birthdate': user.userMetadata?['birthdate'],
      });
    }
  }
}
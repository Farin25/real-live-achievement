import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';

import 'auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;
  final appLinks = AppLinks();

  // Deep link handler (Email confirm / magic link)
  appLinks.uriLinkStream.listen((uri) async {
    try {
      final code = uri.queryParameters['code'];

      // PKCE code flow (most common for Supabase email links)
      if (code != null && code.isNotEmpty) {
        await supabase.auth.exchangeCodeForSession(code);
        return;
      }

      // Fallback (if tokens are provided in URL)
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('Auth deep link error: $e');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}

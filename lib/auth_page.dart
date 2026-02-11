import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _msg;

  final supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    setState(() { _loading = true; _msg = null; });
    try {
      await supabase.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
      );
      setState(() {
        _msg = "Sign-up ok. Falls Email-Confirm an ist: Mail bestätigen.";
      });
    } catch (e) {
      setState(() => _msg = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _msg = null; });
    try {
      await supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      setState(() => _msg = "Logged in ✅");
    } catch (e) {
      setState(() => _msg = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    setState(() => _msg = "Logged out");
  }

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return Scaffold(
      appBar: AppBar(title: const Text("Auth")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signUp,
                      child: const Text("Sign Up"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text("Sign In"),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text("Session: ${session != null}"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: session != null ? _signOut : null,
              child: const Text("Sign Out"),
            ),
            const SizedBox(height: 16),
            if (_msg != null) Text(_msg!, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

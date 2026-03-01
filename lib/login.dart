import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'singup.dart';

class SignInPage2 extends StatelessWidget {
  final VoidCallback onContinueAsGuest;
  const SignInPage2({super.key,
  required this.onContinueAsGuest});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [_Logo(),
                _FormContent(onContinueAsGuest: onContinueAsGuest),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: _Logo()),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icon.png',
          width: isSmallScreen ? 120 : 250,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to Up Mark",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  final VoidCallback onContinueAsGuest;

  const _FormContent({
    required this.onContinueAsGuest,
  });

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Eemail
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email eingeben';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 16),

            // pw feld
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mindestens 6 Zeichen';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Passwort',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign in"),
              ),
            ),

            const SizedBox(height: 10),

            // REGISTER BUTTON
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
              child: const Text("Noch keinen Account? Registrieren"),
            ),
            TextButton(
              onPressed: () {
                showDialog(context: context,
                 builder: (context) => AlertDialog(
                  title: const Text(
                    "Ohne Anmeldung fortfahren"
                  ),
                  content: const Text(
                    "Wenn du ohne Anmeldunk fotfährst,"
                    "hast du keinen zugriff auf Cloud-Speicherung "
                    "oder auf soziale Funktionen wie das Ranking usw.",
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), 
                    child: const Text("Abbrsechen")),
                    ElevatedButton(onPressed: () {
                      Navigator.pop(context);
                      widget.onContinueAsGuest();
                    },
                    child: const Text("Ich verstehe die Risiken"),
                    ),
                  ],
                 ),
                 );
              },
              child: const Text("ohne Anmeldung Weitermachen"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      // 🔥 Email Bestätigung prüfen
      if (user != null && user.emailConfirmedAt == null) {
        await supabase.auth.signOut(scope: SignOutScope.local);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bitte bestätige zuerst deine Email-Adresse."),
          ),
        );

        setState(() => _isLoading = false);
        return;
      }

      // Wenn email bestätigt dannb AuthGate übernimmt automatisch

    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
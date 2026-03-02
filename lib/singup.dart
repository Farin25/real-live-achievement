import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;
  String? _usernameError;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Vorname
              _buildTextField(_firstNameController, "Vorname"),

              const SizedBox(height: 16),

              // Nachname
              _buildTextField(_lastNameController, "Nachname"),

              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: const OutlineInputBorder(),
                  errorText: _usernameError,

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "username eingeben";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              _buildTextField(_emailController, "Email"),

              const SizedBox(height: 16),

              // Passwort
              _buildTextField(_passwordController, "Passwort", isPassword: true),

              const SizedBox(height: 16),

              // Geburtsdatum
              ListTile(
                title: Text(
                  _birthDate == null
                      ? "Geburtsdatum auswählen"
                      : "Geburtsdatum: ${_birthDate!.toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2005),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),

              const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {

                  if (!_formKey.currentState!.validate()) return;

                  if (_birthDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Geburtsdatum auswählen")),
                    );
                    return;
                  }
                  final accepted = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("AGB akzeptieren"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mit der Registrierung akzeptierst du die AGB "
                            "und nimmst die Datenschutzerklärung zur Kenntnis.",
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              final Uri url = Uri.parse(
                                  "https://farin25.github.io/real-live-achievement/docs/Rechtliches/agb");
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            },
                            child: const Text("AGB anzeigen"),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Abbrechen"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("AGB akzeptieren"),
                        ),
                      ],
                    ),
                  );
                                    if (accepted != true) return;

                  // username
                  setState(() => _isLoading = true);

                  try {

                    final username = _usernameController.text.trim();

                    setState(() {
                      _usernameError = null;
                    });

                    
                   final exists = await supabase.rpc(
                      'username_exists',
                      params: {'name': username},
                    );

                    if (exists == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dieser Uername ist bereits vergeben"),
                        ),
                      );
                        setState(() {
                          _usernameError = "Dieser Username ist Bereits vergeben";
                          _isLoading = false;
                        }); 

                      return;

                    }
                    // Sing up
                    await supabase.auth.signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      data: {
                        'first_name': _firstNameController.text.trim(),
                        'last_name': _lastNameController.text.trim(),
                        'username': username,
                        'birthdate': _birthDate!.toString().split(' ')[0],
                      },
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Bitte Email bestätigen."),
                      ),
                    );

                    Navigator.pop(context);

                  } on AuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Fehler: $e")),
                      
                    );
                  }

                  setState(() => _isLoading = false);
                  print("Regestierung wir durchgeführt");
                },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrieren"),
                    
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label eingeben";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
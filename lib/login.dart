//login.dart
import 'package:flutter/material.dart';
import 'package:real_live_achievments/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage2 extends StatelessWidget {
  final VoidCallback onContinueAsGuest;
  const SignInPage2({super.key, required this.onContinueAsGuest});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Logo(),
                  _FormContent(onContinueAsGuest: onContinueAsGuest),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: Center(child: _Logo())),
                    Expanded(
                      child: Center(
                        child: _FormContent(
                          onContinueAsGuest: onContinueAsGuest,
                        ),
                      ),
                    ),
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
        Image.asset('assets/icon.png', width: isSmallScreen ? 120 : 250),
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

  const _FormContent({required this.onContinueAsGuest});

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

            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Passwort eingeben';
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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Ohne Anmeldung fortfahren"),
                    content: const Text(
                      "Wenn du ohne Anmeldung fortfährst, "
                      "hast du keinen Zugriff auf Cloud-Speicherung "
                      "oder auf soziale Funktionen wie das Ranking usw. "
                      "Der lokale Account befindet sich noch in der Entwicklung, wodurch Fehler auftreten können.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Abbrechen"),
                      ),
                      ElevatedButton(
                        onPressed: () {
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
            ),
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

      if (user != null && user.emailConfirmedAt == null) {
        await supabase.auth.signOut(scope: SignOutScope.local);

        if (!mounted) {
          return;
        }

        showAppSnackBar(context, 'Erst E-Mail-Adresse bestätigen');

        setState(() => _isLoading = false);
        return;
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      showAppSnackBar(context, e.message);
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

//------------------
//----Singup-------
//-----------------

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
              _buildTextField(_firstNameController, "Vorname", required: false),

              const SizedBox(height: 16),

              _buildTextField(_lastNameController, "Nachname", required: false),

              const SizedBox(height: 16),

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

              _buildTextField(_emailController, "Email"),

              const SizedBox(height: 16),

              _buildTextField(
                _passwordController,
                "Passwort",
                isPassword: true,
              ),

              const SizedBox(height: 16),

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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          if (_birthDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Geburtsdatum auswählen"),
                              ),
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
                                        "https://farin25.github.io/real-live-achievement/docs/Rechtliches/agb",
                                      );
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: const Text("AGB anzeigen"),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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

                            if (!context.mounted) return;

                            if (exists == true) {
                              showAppSnackBar(
                                context,
                                'Username bereits vergeben',
                              );
                              setState(() {
                                _usernameError =
                                    "Dieser Username ist Bereits vergeben";
                                _isLoading = false;
                              });

                              return;
                            }

                            await supabase.auth.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              data: {
                                'first_name': _firstNameController.text.trim(),
                                'last_name': _lastNameController.text.trim(),
                                'username': username,
                                'birthdate': _birthDate!.toString().split(
                                  ' ',
                                )[0],
                              },
                            );

                            if (!context.mounted) return;

                            showAppSnackBar(
                              context,
                              'E-Mail-Adresse bestätigen',
                            );
                            Navigator.pop(context);
                          } on AuthException catch (e) {
                            if (context.mounted)
                              showAppSnackBar(context, e.message);
                          } catch (e) {
                            if (context.mounted)
                              showAppSnackBar(context, 'Fehler: $e');
                          }

                          setState(() => _isLoading = false);
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool required = true
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return "$label eingeben";
              }
              return null;
            }
          : null,
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

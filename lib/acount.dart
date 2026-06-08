//Acount.dart
import 'package:flutter/material.dart';
import 'package:real_live_achievments/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_sessionmanager.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? profile;
  String? _usernameError;
  String formatDate(String? date) {
    if (date == null) return "";

    final parsed = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(parsed);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _birthdateController = TextEditingController();

  Future<void> _loadProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        profile = data;
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _birthdateController.text = data['birthdate'] ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;
    final newUsername = _usernameController.text.trim();

    if (newUsername != profile!['username']) {
      final exists = await supabase.rpc(
        'username_exists',
        params: {'name': newUsername},
      );
      if (exists == true) {
        setState(() => _usernameError = "Dieser Username ist bereits vergeben");
        return;
      }
    }

    try {
      await supabase
          .from('profiles')
          .update({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'username': _usernameController.text,
            'birthdate': _birthdateController.text,
          })
          .eq('id', user.id);
      if (mounted) {
        showAppSnackBar(context, 'Profil erfolgreich gespeichert');
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) showAppSnackBar(context, 'Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            profile == null
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile!['username'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${profile!['first_name'] ?? ''} ${profile!['last_name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

            const SizedBox(height: 30),

            Expanded(
              child: profile == null
                  ? const SizedBox()
                  : ListView(
                      children: [
                        TextField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Vorname',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nachname',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'username ',
                            errorText: _usernameError,
                          ),
                          onChanged: (_) =>
                              setState(() => _usernameError = null),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _birthdateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Geburtsdatum',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now(), // Später durch App Release date ersetzen cooles kleines easter egg
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              String formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(pickedDate);

                              setState(() {
                                _birthdateController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 25),

                        ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Änderungen speichern'),
                        ),
                      ],
                    ),
            ),
            if (profile != null) ...[
              Text(
                "Letzte änderung: ${formatDate(profile!['updated_at'])}",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),

              Text(
                "Account erstellt: ${formatDate(profile!['created_at'])}",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Text(
                "Support Informationen",
                style: TextStyle(color: Colors.blueGrey, fontSize: 17),
              ),

              const SizedBox(height: 10),
              Text(
                "Account id: ${(profile!['id'])}",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              Text(
                "Account Nummer: ${(profile!['user_number'])}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 5),
            const Divider(),
            SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await UserSessionmanager.logout();
                },
                child: const Text('Abmelden'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Account wirklich löschen?'),
                      content: const Text(
                        'Dieser Vorgang kann nicht rückgängig gemacht werden.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final user = supabase.auth.currentUser;

                            if (user != null) {
                              await supabase.rpc(
                                'delete_user_account',
                                params: {'uid': user.id},
                              );
                              await supabase.auth.signOut(
                                scope: SignOutScope.global,
                              );
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Löschen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  );
                },
                child: const Text('Account löschen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

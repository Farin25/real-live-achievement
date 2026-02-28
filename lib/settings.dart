import 'package:flutter/material.dart';
import 'acount.dart';
import 'licenses.dart';
import 'about.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const SettingsPage({super.key,
  required this.onThemeChanged});


  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            /// PROFILE CARD
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: profile == null
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).primaryColor,
                            child: const Icon(Icons.person,
                                size: 35, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),

            /// SETTINGS LIST
            Expanded(
              child: ListView(
                children: [

                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text("Dark Mode"),
                    subtitle: const Text("Mein Tip: Immer an machen"),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (Value) {
                        if (Value) {
                          widget.onThemeChanged(ThemeMode.dark);

                        }
                        else {
                          widget.onThemeChanged(ThemeMode.light);
                        }
                      },
                    ),
                  ),
               

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Sprache"),
                    subtitle: const Text("Deutsch DE"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Sprachen kommen bald')),
                      );
                    },
                  ),

                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("App Settings"),
                    subtitle:  Text("Berechtigung, Benachrichtigungen usw..."),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await openAppSettings();
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text(
                        "Open Source Lizenzen"),
                    subtitle: const Text(
                        "Verwendete Bibliotheken"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LicensesPage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Info"),
                    subtitle:
                        const Text("Über die App"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                 AboutPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
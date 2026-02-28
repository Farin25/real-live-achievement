import 'dart:ffi';

import 'package:flutter/material.dart';
import 'acount.dart';
import 'licenses.dart';
import 'about.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
                    leading: const Icon(Icons.notifications_active),
                    title: const Text(
                        "App Benachrichtigungen"),
                    subtitle: const Text(
                        "Benachrichtigungen"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Appmessages()),
                      );
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



//App BEnachrichtigungen setings seite:



class Appmessages extends StatefulWidget {
  const Appmessages({super.key});

  @override
  State<Appmessages> createState() => _Appmessages();
}

class _Appmessages extends State<Appmessages> {

  bool pushnewFriendship = true;
  bool pushFriendnewAchievment = true;
  bool pushnewAchievment = true;
  bool Achievmentfasterricht = true;

  // für Master Schalter
  bool get notifyAll =>
    pushnewFriendship &&
    pushFriendnewAchievment &&
    pushnewAchievment &&
    Achievmentfasterricht;
  
  @override
  void initState() {
    super.initState();
    loadSettings();
  }
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Benachrichtigungen"),
      ),
      body: ListView(
        children: [

          SwitchListTile(
            title: Text("Beachrichtigungen"),
            subtitle: const Text("Benachrichtigungen von der App",
            style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: notifyAll,
            onChanged: (value) {
              setState(() {
                pushnewFriendship = value;
                pushFriendnewAchievment = value;
                pushnewAchievment = value;
                Achievmentfasterricht = value;
              });
              saveSettings();
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text("Fast ereichtes Achievment"),
            subtitle: const Text("Wenn du kurtz davor bist ein Achivemnt zu ereichen"),
            value: Achievmentfasterricht,
            onChanged: (value) {
              setState(() {
                Achievmentfasterricht = value;
              });
              saveSettings();
            },
          ),


          SwitchListTile(
            title: const Text("Neuem Achievment"),
            subtitle: const Text("Wenn due in neues Achievment Freigeschaltet hast"),
            value: pushnewAchievment,
            onChanged: (value) {
              setState(() {
                pushnewAchievment = value;
              });
              saveSettings();
            },
          ),

          const Divider(),
          // Freunde Subtitel
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Freunde",
          style:
          TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
        ),
 
          SwitchListTile(
            title: const Text("Freunde Neues Achievment"),
            subtitle: const Text("wenn einer deiner Freunde Ein Neues Achievment bekommen hat"),
            value: pushFriendnewAchievment,
            onChanged: (value) {
              setState(() {
                pushFriendnewAchievment = value;
              });
              saveSettings();
            }
          ),

          SwitchListTile(
            title: const Text("Freundschaftsanfragen"),
            subtitle: const Text("Wennd du eine Neue Freundschaftsanftage bekommst"),
            value: pushnewFriendship,
            onChanged: (value) {
              setState(() {
                pushnewFriendship = value;
              });
              saveSettings();
            },
          ),

         const Divider(),
        ],
      ),
    );
  }

  Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('pushnewFriendship', pushnewFriendship);
  await prefs.setBool('pushFriendnewAchievment', pushFriendnewAchievment);
  await prefs.setBool('pushnewAchievment', pushnewAchievment);
  await prefs.setBool('Achievmentfasterricht', Achievmentfasterricht);
}

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    pushnewFriendship =
        prefs.getBool('pushnewFriendship') ?? true;

    pushFriendnewAchievment =
        prefs.getBool('pushFriendnewAchievment') ?? true;

    pushnewAchievment =
        prefs.getBool('pushnewAchievment') ?? true;

    Achievmentfasterricht =
        prefs.getBool('Achievmentfasterricht') ?? true;
  });
}

}

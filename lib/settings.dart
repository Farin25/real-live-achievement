//settings.dart
import 'package:flutter/material.dart';
import 'package:real_live_achievments/engine_helpers.dart';
import 'acount.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AppConfig {
  static const String appname = "Up Mark";
  static const String version = "BETA 0.5(dev)";
  static const String website =
      "https://farin25.github.io/real-live-achievement/";
}

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const SettingsPage({super.key, required this.onThemeChanged});

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
                  MaterialPageRoute(builder: (context) => const AccountPage()),
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
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
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
              ),
            ),

            const SizedBox(height: 10),
            const Divider(),

            /// SETTINGS LIST
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.design_services),
                    title: const Text("Design"),
                    subtitle: const Text("Dark Mode, Farben, Theme"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Design(onThemeChanged: widget.onThemeChanged),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Sprache"),
                    subtitle: const Text("Deutsch DE"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sprachen kommen bald')),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text("App Benachrichtigungen"),
                    subtitle: const Text("Benachrichtigungen"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Appmessages(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Erweiterte Einstellungen"),
                    subtitle: const Text("Die Einstellungen für Experten"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedSettings(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text("Open Source Lizenzen"),
                    subtitle: const Text("Verwendete Bibliotheken"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LicensesPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Info"),
                    subtitle: const Text("Über die App"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("App Settings"),
                    subtitle: Text("Berechtigung, usw..."),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await openAppSettings();
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

//--------------------------
//--------Notifications------
//--------------------------
class Appmessages extends StatefulWidget {
  const Appmessages({super.key});

  @override
  State<Appmessages> createState() => _Appmessages();
}

class _Appmessages extends State<Appmessages> {
  bool notifynewFriendship = true;
  bool notifyFriendnewAchievment = true;
  bool notifynewAchievment = true;
  bool notifyAchievmentfasterricht = true;
  bool notifyemailbirthday = true;

  // für Master Schalter
  bool get notifyAll =>
      notifynewFriendship &&
      notifyFriendnewAchievment &&
      notifynewAchievment &&
      notifyAchievmentfasterricht;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benachrichtigungen")),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Beachrichtigungen"),
            subtitle: const Text(
              "Benachrichtigungen von der App",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: notifyAll,
            onChanged: (value) {
              setState(() {
                notifynewFriendship = value;
                notifyFriendnewAchievment = value;
                notifynewAchievment = value;
                notifyAchievmentfasterricht = value;
              });
              saveSettings();
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text("Fast ereichtes Achievment"),
            subtitle: const Text(
              "Wenn du kurtz davor bist ein Achivemnt zu ereichen",
            ),
            value: notifyAchievmentfasterricht,
            onChanged: (value) {
              setState(() {
                notifyAchievmentfasterricht = value;
              });
              saveSettings();
              print(
                "Benachrichtigungsettings Aktualliesiert: Achievmentfasteerreicht = $notifyAchievmentfasterricht ",
              );
            },
          ),

          SwitchListTile(
            title: const Text("Neuem Achievment"),
            subtitle: const Text(
              "Wenn due in neues Achievment Freigeschaltet hast",
            ),
            value: notifynewAchievment,
            onChanged: (value) {
              setState(() {
                notifynewAchievment = value;
              });
              saveSettings();
              print(
                "Benachrichtigungs Einstellungen Aktualliesiert: pushnewachievment = $notifynewAchievment",
              );
            },
          ),

          const Divider(),
          // Freunde Subtitel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Freunde",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            title: const Text("Freunde Neues Achievment"),
            subtitle: const Text(
              "wenn einer deiner Freunde Ein Neues Achievment bekommen hat",
            ),
            value: notifyFriendnewAchievment,
            onChanged: (value) {
              setState(() {
                notifyFriendnewAchievment = value;
              });
              saveSettings();
              print(
                "Benachrichtigungs Einstellungen Aktualliesiert: pushFriendnewAchievment = $notifyFriendnewAchievment",
              );
            },
          ),

          SwitchListTile(
            title: const Text("Freundschaftsanfragen"),
            subtitle: const Text(
              "Wennd du eine Neue Freundschaftsanftage bekommst",
            ),
            value: notifynewFriendship,
            onChanged: (value) {
              setState(() {
                notifynewFriendship = value;
              });
              saveSettings();
              print(
                "Benachrichtigungs Einstellungen Aktualliesiert: pushnewFriendship = $notifynewFriendship",
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Email Benachrichtigungen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Geburstagswünsche"),
            subtitle: const Text(
              "Erhalte an deinem Geburstag eine email von uns.",
            ),
            value: notifyemailbirthday,
            onChanged: (value) {
              setState(() {
                notifyemailbirthday = value;
              });
              saveSettings();
              print(
                "Benachrichtigungs Einstellungen Aktualliesiert: notifyemailbirthday = $notifyemailbirthday",
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('pushnewFriendship', notifynewFriendship);
    await prefs.setBool('pushFriendnewAchievment', notifyFriendnewAchievment);
    await prefs.setBool('pushnewAchievment', notifynewAchievment);
    await prefs.setBool(
      'pufhAchievmentfasterricht',
      notifyAchievmentfasterricht,
    );
    await prefs.setBool('notifyemailbirthday', notifyemailbirthday);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notifynewFriendship = prefs.getBool('pushnewFriendship') ?? true;

      notifyFriendnewAchievment =
          prefs.getBool('pushFriendnewAchievment') ?? true;

      notifynewAchievment = prefs.getBool('pushnewAchievment') ?? true;

      notifyAchievmentfasterricht =
          prefs.getBool('Achievmentfasterricht') ?? true;

      notifyemailbirthday = prefs.getBool('notifyemailbirthday') ?? true;
    });
  }
}
// Design Wichtig und Richtig

class Design extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const Design({super.key, required this.onThemeChanged});

  @override
  State<Design> createState() => _Design();
}

class _Design extends State<Design> {
  String lockedVisibility = 'all';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(title: const Text("Design & Stil")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.design_services),
            title: const Text("Dark Mode"),
            subtitle: const Text("Meine Empfehlung: Immer an"),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (Value) async {
                if (Value) {
                  widget.onThemeChanged(ThemeMode.dark);
                } else {
                  widget.onThemeChanged(ThemeMode.light);
                }
                print(
                  "Dark Mode Settings Aktualliesiert auf: ThemeMMode = $ThemeMode.",
                );
                (await SharedPreferences.getInstance()).setInt(
                  'themeChangeTime',
                  DateTime.now().millisecondsSinceEpoch,
                );
                (await SharedPreferences.getInstance()).setString(
                  'currentThemeMode',
                  Value ? 'dark' : 'light',
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Gesperrte Achievements"),
            subtitle: const Text("Was soll angezeigt werden?"),
            trailing: DropdownButton<String>(
              value: lockedVisibility,
              items: [
                DropdownMenuItem(value: 'all', child: Text('Alles')),
                DropdownMenuItem(value: 'name_only', child: Text('Nur Name')),
                DropdownMenuItem(value: 'hidden', child: Text('Versteckt')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => lockedVisibility = value);
                  saveSettings();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locked_visibility', lockedVisibility);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lockedVisibility = prefs.getString('locked_visibility') ?? 'all';
    });
  }
}

//---------------------------------------
//-------Erweitertte Einstellungen-------
//---------------------------------------
class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  bool achievementDownloadOverWifi = true;
  int engineTimerMinutes = 30;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Erweiterte Einstellungen")),
      body: ListView(
        children: [
          // WLAN Switch
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text("Achievements WLAN Download"),
            subtitle: const Text(
              "Achievements nur bei WLAN Verbindung herunterladen",
            ),
            value: achievementDownloadOverWifi,
            onChanged: (value) {
              setState(() => achievementDownloadOverWifi = value);
              saveSettings();
            },
          ),
          const Divider(),

          // Timer Setting
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text("Engine Timer (Minuten)"),
            subtitle: Text("Aktuell: $engineTimerMinutes Minuten"),
            onTap: () async {
              final newValue = await showDialog<int>(
                context: context,
                builder: (context) {
                  int tempValue = engineTimerMinutes;
                  return AlertDialog(
                    title: const Text("Achievments Prüfen"),
                    content: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Minuten"),
                      onChanged: (val) {
                        tempValue = int.tryParse(val) ?? engineTimerMinutes;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text("Abbrechen"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, tempValue),
                        child: const Text("Speichern"),
                      ),
                    ],
                  );
                },
              );

              if (newValue != null) {
                setState(() => engineTimerMinutes = newValue);
                saveSettings();
                EngineRunner.instance?.restartTimer();
                print("Engine Timer auf $engineTimerMinutes Minuten gesetzt");
              }
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Debug/Developer Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text("Engine manuell starten"),
            subtitle: const Text("Startet die Achievement-Engine sofort"),
            onTap: () {
              runEngine();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Engine wurde gestartet")),
              );
              print('Engine wurde Manuell gestartet');
            },
          ),
        ],
      ),
    );
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'achievementDownloadOverWifi',
      achievementDownloadOverWifi,
    );
    await prefs.setInt('engineTimerMinutes', engineTimerMinutes);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      achievementDownloadOverWifi =
          prefs.getBool('achievementDownloadOverWifi') ?? true;
      engineTimerMinutes = prefs.getInt('engineTimerMinutes') ?? 10;
    });
  }
}

// About Seite
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Über die App')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              //Icon
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // Lädt Icon
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // App Name
            Center(
              child: Text(
                AppConfig.appname,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // Version
            Center(
              child: Text(
                AppConfig.version,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 30),

            // Beschreibung
            Text(
              'Über die App:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Up Mark motiviert dich, echte Ziele im Leben zu erreichen! '
              'Sammle Achievements im Echten Leben! '
              'Teile deine Erfolge mit Freunden und lass dich von ihren Achievements inspirieren.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),

            VimeoVideo(),

            SizedBox(height: 30),

            Text(
              'Links:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            linkTile(
              'Webseite',
              'https://farin25.github.io/real-live-achievement/',
            ),
            linkTile(
              'Eigenes Achievment Einreichen',
              'https://farin25.github.io/real-live-achievement/docs/Dein_Achievment/',
            ),
            linkTile(
              'Newsletter',
              'https://farin25.github.io/real-live-achievement/docs/newsletter',
            ),
            linkTile(
              'SourceCode',
              'https://github.com/Farin25/real-live-achievement',
            ),
            linkTile(
              'Changelog',
              'https://farin25.github.io/real-live-achievement/docs/Changelog',
            ),

            SizedBox(height: 10),

            Text(
              'Rechtliches:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            linkTile(
              'Impressum',
              'https://farin25.github.io/real-live-achievement/docs/Rechtliches/impressum/',
            ),
            linkTile(
              'Datenschutzerklärung',
              'https://github.com/Farin25/real-live-achievement',
            ),
            linkTile(
              'Algemeine Gschäfts Bedingungen',
              'http://localhost:3000/real-live-achievement/docs/Rechtliches/agb',
            ),
            linkTile(
              'FAQ',
              'https://farin25.github.io/real-live-achievement/docs/FAQ',
            ),

            //MAil
            linkTile(
              'Support kontaktieren oder Fehler melden',
              'mailto:Achievments@holzideen.org?subject=Support%20RealLiveAchievement&body=Hallo,%0A%0Aich%20habe%20folgendes%20Problem:%0A',
            ),

            SizedBox(height: 10),

            Text(
              'Dankesagung:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.white),
                children: [
                  TextSpan(
                    text:
                        'Ein großer dank geht an alle tester der Beta Version und an alle Lehrer*innen die an uns Geglaubt haben und es ermöglich haben dieses Projekt im rahmen den Projekt orientiertes lernen zu machen. Wir bedanken uns auch bei allen die Eine Idee für ein Acheievment Eingereicht haben un und Feedback zur App gegeben haben. ',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Entwickler / Herausgeber:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Farin Langner',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri url = Uri.parse('https://farin-langner.de');
                        await launchUrl(url, mode: LaunchMode.platformDefault);
                      },
                  ),

                  TextSpan(
                    text: ' & ',
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Liam Selent',
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            Text(
              '© 2025-2026 Farin Langner & Liam Selent Alle Rechte Vorbehalten',
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
              ),
            ),
          ],
        ),
      ),
      //
    );
  }
}

// URLS
Widget linkTile(String title, String url) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
    ),
    onTap: () async {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    },
  );
}

//--------------------------
//-------- Lizenzen Seite----
//---------------------------
class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LicensePage(
        applicationName: AppConfig.appname,
        applicationVersion: AppConfig.version,
      ),
    );
  }
}

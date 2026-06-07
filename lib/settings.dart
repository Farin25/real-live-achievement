// settings.dart
import 'package:flutter/material.dart';
import 'package:real_live_achievments/engine_helpers.dart';
import 'acount.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

//--------------------------
//-------- Settings Service -
//--------------------------
class SettingsService {
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> loadBool(String key, bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'currentThemeMode',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    await prefs.setInt(
      'themeChangeTime',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int> loadInt(String key, int defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String> loadString(String key, String defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
}

//--------------------------
//-------- Settings Page ----
//--------------------------
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
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.design_services),
                    title: const Text("Design"),
                    subtitle: const Text("Dark Mode, Farben, Theme"),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                      showAppSnackBar(context, 'Sprachen kommen bald');
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
                          builder: (context) => const AppMessages(),
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
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("App Einstellungen"),
                    subtitle: const Text("Berechtigungen, usw."),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
//-------- Benachrichtigungen
//--------------------------
class AppMessages extends StatefulWidget {
  const AppMessages({super.key});

  @override
  State<AppMessages> createState() => _AppMessagesState();
}

class _AppMessagesState extends State<AppMessages> {
  bool notifyNewFriendship = true;
  bool notifyFriendNewAchievement = true;
  bool notifyNewAchievement = true;
  bool notifyAchievementAlmostReached = true;
  bool notifyEmailBirthday = true;

  bool get notifyAll =>
      notifyNewFriendship &&
      notifyFriendNewAchievement &&
      notifyNewAchievement &&
      notifyAchievementAlmostReached;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benachrichtigungen")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Benachrichtigungen"),
            subtitle: const Text(
              "Benachrichtigungen von der App",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: notifyAll,
            onChanged: (value) {
              setState(() {
                notifyNewFriendship = value;
                notifyFriendNewAchievement = value;
                notifyNewAchievement = value;
                notifyAchievementAlmostReached = value;
              });
              _saveSettings();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Fast erreichtes Achievement"),
            subtitle: const Text(
              "Wenn du kurz davor bist ein Achievement zu erreichen",
            ),
            value: notifyAchievementAlmostReached,
            onChanged: (value) {
              setState(() => notifyAchievementAlmostReached = value);
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text("Neues Achievement"),
            subtitle: const Text(
              "Wenn du ein neues Achievement freigeschaltet hast",
            ),
            value: notifyNewAchievement,
            onChanged: (value) {
              setState(() => notifyNewAchievement = value);
              _saveSettings();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Freunde",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Freunde neues Achievement"),
            subtitle: const Text(
              "Wenn einer deiner Freunde ein neues Achievement bekommen hat",
            ),
            value: notifyFriendNewAchievement,
            onChanged: (value) {
              setState(() => notifyFriendNewAchievement = value);
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text("Freundschaftsanfragen"),
            subtitle: const Text(
              "Wenn du eine neue Freundschaftsanfrage bekommst",
            ),
            value: notifyNewFriendship,
            onChanged: (value) {
              setState(() => notifyNewFriendship = value);
              _saveSettings();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "E-Mail Benachrichtigungen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Geburtstagswünsche"),
            subtitle: const Text(
              "Erhalte an deinem Geburtstag eine E-Mail von uns.",
            ),
            value: notifyEmailBirthday,
            onChanged: (value) {
              setState(() => notifyEmailBirthday = value);
              _saveSettings();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await SettingsService.saveBool('pushNewFriendship', notifyNewFriendship);
    await SettingsService.saveBool(
      'pushFriendNewAchievement',
      notifyFriendNewAchievement,
    );
    await SettingsService.saveBool('pushNewAchievement', notifyNewAchievement);
    await SettingsService.saveBool(
      'pushAchievementAlmostReached',
      notifyAchievementAlmostReached,
    );
    await SettingsService.saveBool('notifyEmailBirthday', notifyEmailBirthday);
  }

  Future<void> _loadSettings() async {
    final newFriendship = await SettingsService.loadBool(
      'pushNewFriendship',
      true,
    );
    final friendAchievement = await SettingsService.loadBool(
      'pushFriendNewAchievement',
      true,
    );
    final newAchievement = await SettingsService.loadBool(
      'pushNewAchievement',
      true,
    );
    final almostReached = await SettingsService.loadBool(
      'pushAchievementAlmostReached',
      true,
    );
    final emailBirthday = await SettingsService.loadBool(
      'notifyEmailBirthday',
      true,
    );
    setState(() {
      notifyNewFriendship = newFriendship;
      notifyFriendNewAchievement = friendAchievement;
      notifyNewAchievement = newAchievement;
      notifyAchievementAlmostReached = almostReached;
      notifyEmailBirthday = emailBirthday;
    });
  }
}

//--------------------------
//-------- Design -----------
//--------------------------
class Design extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const Design({super.key, required this.onThemeChanged});

  @override
  State<Design> createState() => _DesignState();
}

class _DesignState extends State<Design> {
  String lockedVisibility = 'all';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (value) async {
                final newMode = value ? ThemeMode.dark : ThemeMode.light;
                widget.onThemeChanged(newMode);
                await SettingsService.saveTheme(newMode);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Gesperrte Achievements"),
            subtitle: const Text("Was soll angezeigt werden?"),
            trailing: DropdownButton<String>(
              value: lockedVisibility,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Alles')),
                DropdownMenuItem(value: 'name_only', child: Text('Nur Name')),
                DropdownMenuItem(value: 'hidden', child: Text('Versteckt')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => lockedVisibility = value);
                  _saveSettings();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await SettingsService.saveString('locked_visibility', lockedVisibility);
  }

  Future<void> _loadSettings() async {
    final value = await SettingsService.loadString(
      'locked_visibility',
      lockedVisibility,
    );
    setState(() => lockedVisibility = value);
  }
}

//-----------------------------------------
//-------- Erweiterte Einstellungen --------
//-----------------------------------------
class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  bool achievementDownloadOverWifi = true;
  int engineTimerMinutes = 10;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Erweiterte Einstellungen")),
      body: ListView(
        children: [
          const Divider(),
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
                    title: const Text("Achievements prüfen"),
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
                _saveSettings();
                EngineRunner.instance?.restartTimer();
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Debug / Developer Settings",
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
              showAppSnackBar(context, 'Engine wurde gestartet');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await SettingsService.saveBool(
      'achievementDownloadOverWifi',
      achievementDownloadOverWifi,
    );
    await SettingsService.saveInt('engineTimerMinutes', engineTimerMinutes);
  }

  Future<void> _loadSettings() async {
    final wifi = await SettingsService.loadBool(
      'achievementDownloadOverWifi',
      true,
    );
    final timer = await SettingsService.loadInt('engineTimerMinutes', 10);
    setState(() {
      achievementDownloadOverWifi = wifi;
      engineTimerMinutes = timer;
    });
  }
}

//--------------------------
//-------- Über die App ----
//--------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(title: const Text('Über die App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                AppConfig.appname,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                AppConfig.version,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Über die App:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'AchieveIRL motiviert dich, echte Ziele im Leben zu erreichen! '
              'Sammle Achievements im echten Leben! '
              'Teile deine Erfolge mit Freunden und lass dich von ihren Achievements inspirieren.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Links:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            linkTile('Webseite', 'https://achieveirl.de/'),
            linkTile(
              'Eigenes Achievement einreichen',
              'https://achieveirl.de/achievements/einreichen',
            ),
            linkTile('Dankesagung', 'https://achieveirl.de/danksagung'),
            linkTile('Newsletter', 'https://achieveirl.de/newsletter'),
            linkTile('Beta', 'https://achieveirl.de/beta'),

            linkTile(
              'SourceCode',
              'https://github.com/Farin25/real-live-achievement',
            ),
            linkTile('Changelog', 'https://achieveirl.de/changelog'),
            const SizedBox(height: 10),
            const Text(
              'Rechtliches:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            linkTile('Impressum', 'https://legal.farin-langner.de/#impressum'),
            linkTile(
              'Datenschutzerklärung',
              'https://legal.farin-langner.de/#ds-upmark',
            ),
            linkTile(
              'Allgemeine Geschäftsbedingungen',
              'https://legal.farin-langner.de/#agb',
            ),
            linkTile('FAQ', 'https://achieveirl.de/faq'),
            linkTile(
              'Support kontaktieren oder Fehler melden',
              'mailto:liam_and_farin@holzideen.org?subject=Support%20RealLiveAchievement&body=Hallo,%0A%0Aich%20habe%20folgendes%20Problem:%0A',
            ),

            const SizedBox(height: 20),
            const Text(
              'Entwickler / Herausgeber:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: textColor),
                children: [
                  TextSpan(
                    text: 'Farin Langner',
                    style: const TextStyle(
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
                    style: TextStyle(color: textColor),
                  ),
                  TextSpan(
                    text: 'Liam Selent',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '© 2025-2026 Farin Langner & Liam Selent Alle Rechte Vorbehalten',
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

//--------------------------
//-------- Link Tile --------
//--------------------------
Widget linkTile(String title, String url) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: const TextStyle(
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
//-------- Lizenzen --------
//--------------------------
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

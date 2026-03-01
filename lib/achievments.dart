import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// https://pub.dev/packages/shared_preferences
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
//Für Nur Wlan download
import 'package:connectivity_plus/connectivity_plus.dart';


class AchievmentSeite extends StatefulWidget {
  const AchievmentSeite({super.key});

  @override
  State<AchievmentSeite> createState() => _AchievmentSeiteState();
}

class _AchievmentSeiteState extends State<AchievmentSeite> {
  List<dynamic> _achievements = [];
  List<dynamic> _userAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadlocalAchievments();
    _loadAchievements();
  }





  Future<void> _loadAchievements() async {

   final connectivityResult = await Connectivity().checkConnectivity();
   final prefs = await SharedPreferences.getInstance();
   final achievementDownloadOverWifi =
    prefs.getBool('achievementDownloadOverWifi') ?? true;


    if (achievementDownloadOverWifi &&
        connectivityResult != ConnectivityResult.wifi) {
      print("Keine WLAN verbindung Achievment Download übersprungen");
      return;
    }


    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;


    if (user == null) return;

    try {
      final achievements = await supabase
          .from('achievements')
          .select();

      final userAchievements = await supabase
          .from('user_achievements')
          .select()
          .eq('user_id', user.id);

      final prefs = await SharedPreferences.getInstance();

       await prefs.setString(
          'cached_achievements',
          jsonEncode(achievements),
        );

      setState(() {
        _achievements = achievements;
        _userAchievements = userAchievements;
        _isLoading = false;
      });

    } catch (e) {
      print("Fehler beim achievments Laden: $e");
    }
  }

  Future<void> _loadlocalAchievments() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_achievements');

    if (cached != null) {
      setState(() {
        _achievements = jsonDecode(cached);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Achievements")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _achievements.length,
              itemBuilder: (context, index) {

                final achievement = _achievements[index];

                final unlocked = _userAchievements.any(
                  (ua) => ua['achievement_id'] == achievement['id'],
                );

                return ListTile(
                  leading: Icon(
                    unlocked ? Icons.emoji_events : Icons.lock,
                    color: unlocked ? Colors.amber : Colors.grey,
                  ),
                  title: Text(achievement['name']),
                  subtitle: Text(achievement['description']),
                );
              },
            ),
    );
  }
}







/*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievments'),
      ),
      body: Center(
        child: Text('Hier Entsteht die Achievments Seite.......',
        style: TextStyle(fontSize: 20),
      ),
     ),
    );
  }
*/



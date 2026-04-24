// achievements.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  String _lockedVisibility = 'all';

  @override
  void initState() {
    super.initState();
    _loadLockedVisibility();
    _loadlocalAchievments();
    _loadAchievements();
  }

  Future<void> _loadLockedVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockedVisibility = prefs.getString('locked_visibility') ?? 'all';
    });
  }

  Future<void> _loadAchievements() async {
    // Wlan prüfung
    final connectivityResult = await Connectivity().checkConnectivity();
    final prefs = await SharedPreferences.getInstance();
    final achievementDownloadOverWifi =
        prefs.getBool('achievementDownloadOverWifi') ?? true;

    if (achievementDownloadOverWifi &&
        connectivityResult != ConnectivityResult.wifi) {
      print("Keine WLAN verbindung Achievement Download übersprungen");
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final achievements = await supabase.from('achievements').select();
      final userAchievements = await supabase
          .from('user_achievements')
          .select()
          .eq('user_id', user.id);

      await prefs.setString('cached_achievements', jsonEncode(achievements));

      setState(() {
        _achievements = achievements;
        _userAchievements = userAchievements;
        _isLoading = false;
      });
    } catch (e) {
      print("Fehler beim Achievements Laden: $e");
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

  DateTime? _unlockedAt(dynamic achievement) {
    try {
      final ua = _userAchievements.firstWhere(
        (ua) => ua['achievement_id'] == achievement['id'],
      );
      final raw = ua['unlocked_at'];
      return raw != null ? DateTime.tryParse(raw) : null;
    } catch (_) {
      return null;
    }
  }

  bool _isUnlocked(dynamic achievement) => _unlockedAt(achievement) != null;

  void _showAchievementPopup(dynamic achievement, bool unlocked) {
    // lockedVisibility bestimmt was bei gesperrten angezeigt wird
    final showDescription = unlocked || _lockedVisibility == 'all';
    final showName =
        unlocked ||
        _lockedVisibility == 'all' ||
        _lockedVisibility == 'name_only';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon oben
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
              ),
              child: Icon(
                unlocked ? Icons.emoji_events : Icons.lock,
                size: 36,
                color: unlocked ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              showName ? achievement['name'] : '???',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Kategorie
            if (showName && achievement['category'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Text(
                  achievement['category'],
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ),
            const SizedBox(height: 12),

            // Beschreibung
            if (showDescription && achievement['description'] != null)
              Text(
                achievement['description'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

            // Wenn hidden
            if (!showName)
              Text(
                'Dieses Achievement ist noch gesperrt.',
                style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),

            // Freigeschaltet am
            if (unlocked) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 6),
                  Builder(
                    builder: (context) {
                      final date = _unlockedAt(achievement);
                      final label = date != null
                          ? 'Freigeschaltet am ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
                          : 'Freigeschaltet';
                      return Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[600],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Achievements aufteilen in freigeschaltet und gesperrt
    final unlocked = _achievements.where((a) => _isUnlocked(a)).toList();
    final locked = _achievements.where((a) => !_isUnlocked(a)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        // Zähler oben rechts
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${unlocked.length} / ${_achievements.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Freigeschaltete Sektion
                if (unlocked.isNotEmpty) ...[
                  _sectionLabel('Freigeschaltet'),
                  _buildGrid(unlocked, true),
                  const SizedBox(height: 24),
                ],

                // Gesperrte Sektion
                if (locked.isNotEmpty) ...[
                  _sectionLabel('Gesperrt'),
                  _buildGrid(locked, false),
                ],
              ],
            ),
    );
  }

  // Hilfsmethode: Überschrift für eine Sektion
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // Hilfsmethode: baut das Grid für eine Liste von Achievements
  Widget _buildGrid(List<dynamic> achievements, bool unlocked) {
    return GridView.builder(
      // wichtig: damit GridView in einem ListView funktioniert
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 Kacheln pro Reihe
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildTile(achievement, unlocked);
      },
    );
  }

  // Hilfsmethode: eine einzelne Kachel
  Widget _buildTile(dynamic achievement, bool unlocked) {
    return GestureDetector(
      onTap: () => _showAchievementPopup(achievement, unlocked),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: unlocked
              ? Colors.blue.withOpacity(0.1)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: unlocked
                ? Colors.blue.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock,
              size: 28,
              color: unlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                // bei name_only oder hidden gesperrte Namen verstecken
                unlocked || _lockedVisibility != 'hidden'
                    ? achievement['name']
                    : '???',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: unlocked ? Colors.blue[800] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

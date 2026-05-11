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

  Color _categoryColor(String? category) {
    switch (category) {
      case 'Fun':
        return Colors.red;
      case 'Adventure & Travel':
        return Colors.orange;
      case 'Fitness & Health':
        return Colors.pink;
      case 'App':
        return Colors.blue;
      case 'Nature':
        return Colors.green;
      case 'Events':
        return Colors.yellow;
      case 'Sponsored':
        return Colors.grey;
      default:
        return Colors.black12;
    }
  }

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
    final categoryColor = _categoryColor(achievement['category']);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final showDescription = unlocked || _lockedVisibility == 'all';
    final showName =
        unlocked ||
        _lockedVisibility == 'all' ||
        _lockedVisibility == 'name_only';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: unlocked
            ? (isDark
                  ? Color.lerp(categoryColor, Colors.black, 0.7)
                  : Color.lerp(categoryColor, Colors.white, 0.85))
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: unlocked ? categoryColor : null),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.8))
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              child: Icon(
                unlocked ? Icons.emoji_events : Icons.lock,
                size: 36,
                color: unlocked ? categoryColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              showName ? achievement['name'] : '???',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: unlocked ? categoryColor : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            if (showName && achievement['category'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.85),
                ),
                child: Text(
                  achievement['category'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            if (showDescription && achievement['description'] != null)
              Text(
                achievement['description'],
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

            if (!showName)
              Text(
                'Dieses Achievement ist noch gesperrt.',
                style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),

            if (unlocked) ...[
              const SizedBox(height: 12),
              Divider(
                color: categoryColor.withValues(alpha: 0.4),
              ), // von 0.3 auf 0.4
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: categoryColor),
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
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
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
    final unlocked = _achievements.where((a) => _isUnlocked(a)).toList();
    final locked = _achievements.where((a) => !_isUnlocked(a)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),

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
                if (unlocked.isNotEmpty) ...[
                  _sectionLabel('Freigeschaltet'),
                  _buildGrid(unlocked, true),
                  const SizedBox(height: 24),
                ],

                if (locked.isNotEmpty) ...[
                  _sectionLabel('Gesperrt'),
                  _buildGrid(locked, false),
                ],
              ],
            ),
    );
  }

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

  Widget _buildGrid(List<dynamic> achievements, bool unlocked) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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

  Widget _buildTile(dynamic achievement, bool unlocked) {
    final categoryColor = _categoryColor(achievement['category']);

    return GestureDetector(
      onTap: () => _showAchievementPopup(achievement, unlocked),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: unlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withValues(alpha: 0.25),
                    categoryColor.withValues(alpha: 0.10),
                  ],
                )
              : null,
          color: unlocked ? null : Theme.of(context).cardColor,
          border: Border.all(
            color: unlocked
                ? categoryColor.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.2),
            width: unlocked ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock,
              size: 28,
              color: unlocked ? categoryColor : Colors.grey,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                unlocked || _lockedVisibility != 'hidden'
                    ? achievement['name']
                    : '???',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? categoryColor : Colors.grey[600],
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

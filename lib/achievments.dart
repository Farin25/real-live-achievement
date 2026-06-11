// achievements.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';

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

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadLockedVisibility();
    _loadAchievements();
  }

  Future<void> _loadLockedVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockedVisibility = prefs.getString('locked_visibility') ?? 'all';
    });
  }

  Future<void> _loadAchievements() async {
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

      setState(() {
        _achievements = achievements;
        _userAchievements = userAchievements;
        _isLoading = false;
      });
    } on SocketException {
      if (kDebugMode) print('Keine Internet Verbindung');
      if (mounted) showAppSnackBar(context, 'Keine Internet Verbindung');
      // Cooller offline screen wie in home
    } catch (e) {
      if (kDebugMode) print("Fehler beim Achievements Laden: $e");
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
    final categoryColor = AppConfig.categoryColor(achievement['category']);

    final showDescription = unlocked || _lockedVisibility == 'all';
    final showName =
        unlocked ||
        _lockedVisibility == 'all' ||
        _lockedVisibility == 'name_only';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: unlocked
                ? categoryColor.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        backgroundColor: AppColors.cardC(context),
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
                borderRadius: BorderRadiusDirectional.circular(12),
                border: Border.all(
                  color: unlocked
                      ? categoryColor.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                unlocked ? Icons.emoji_events : Icons.lock,
                size: 36,
                color: unlocked ? categoryColor : AppColors.subtle(context),
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
                  color: categoryColor.withValues(alpha: 0.15),
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
                  color: AppColors.fg(context),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

            if (!showName)
              Text(
                'Dieses Achievement ist noch gesperrt.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.subtle(context),
                ),
                textAlign: TextAlign.center,
              ),

            if (unlocked) ...[
              const SizedBox(height: 12),
              Divider(color: categoryColor.withValues(alpha: 0.4)),
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
                style: TextStyle(color: AppColors.textMuted),
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
          color: AppColors.muted(context),
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
    final categoryColor = AppConfig.categoryColor(
      achievement['category'] ?? '???',
    );

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
          color: unlocked ? null : AppColors.cardC(context),
          border: Border.all(
            color: unlocked
                ? categoryColor.withValues(alpha: 0.4)
                : AppColors.border,
            width: unlocked ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock,
              size: 28,
              color: unlocked ? categoryColor : AppColors.subtle(context),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                unlocked || _lockedVisibility != 'hidden'
                    ? achievement['name'] ?? '???'
                    : '???',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? categoryColor : AppColors.subtle(context),
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

import 'Achievment_loader.dart';
import 'engine.dart';
import 'user_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementRunner {

  static final supabase = Supabase.instance.client;

  static Future<void> run() async {

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final achievements = await AchievementService.loadAchievements();
    final userStatus = await UserStatusService.getUserStatus();

    final unlockedAchievements = await supabase
        .from('user_achievements')
        .select('achievement_id')
        .eq('user_id', user.id);

    final unlockedIds =
        unlockedAchievements.map((a) => a['achievement_id']).toSet();

    for (var achievement in achievements) {

      final result = AchievmentEngine.evaluate(
        achievement,
        userStatus,
      );

      final achievementId = achievement['id'];

      if (result.unlocked && !unlockedIds.contains(achievementId)) {

        await supabase.from('user_achievements').insert({
          'user_id': user.id,
          'achievement_id': achievementId,
          'unlocked_at': DateTime.now().toIso8601String()
        });

        print("Achievement unlocked: ${achievement['name']}");
      }
    }
  }
}
//engine.dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementEngine {
  final supabase = Supabase.instance.client;

  Future<void> run() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final achievements = await supabase
        .from('achievements')
        .select('id, requirement');

    final unlocked = await supabase
        .from('user_achievements')
        .select('achievement_id')
        .eq('user_id', user.id);

    final unlockedIds = unlocked.map((u) => u['achievement_id']).toSet();

    for (final achievement in achievements) {
      final id = achievement['id'];
      final requirement = achievement['requirement'];

      if (unlockedIds.contains(id)) {
        print('$id: Schon freigeschaltet');
        continue;
      } else {
        print('$id: Noch nicht freigeschaltet: json decoding wird gestartet');
        final Map<String, dynamic> req = requirement is String
            ? jsonDecode(requirement)
            : requirement;

        final mechanism = req['mechanism'];
        print('Mechanism: $mechanism');

        switch (mechanism) {
          case 'simple_threshold':
            final type = req['type'];
            final now = DateTime.now();

            if (type == 'is_friday_13th') {
              if (now.weekday == 5 && now.day == 13) {
                print('Friday the 13th erfüllt!');
                await supabase.from('user_achievements').insert({
                  'user_id': user.id,
                  'achievement_id': id,
                  'unlocked_at': DateTime.now().toIso8601String(),
                });
                print(
                  'Friday the 13th erfolgreich an supabase backend übergeben',
                );
              }
            }
          case 'unique_count':
          case 'combined':
        }
      }
    }
  }
}

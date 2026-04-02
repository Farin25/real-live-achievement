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

    final userdata = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

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
            // Friday the 13th
            if (type == 'is_friday_13th') {
              if (now.weekday == 5 && now.day == 13) {
                print('Friday the 13th erfüllt!');
                await supabase.from('user_achievements').insert({
                  'user_id': user.id,
                  'achievement_id': id,
                  'unlocked_at': DateTime.now().toIso8601String(),
                });
                _logUnlock(id, user.id);
              }
            }
            // Birthday
            if (type == 'is_users_birthday') {
              final birthdayValue = userdata['birthdate'];
              DateTime? birthdayDate;
              if (birthdayValue is String) {
                birthdayDate = DateTime.tryParse(birthdayValue);
              } else if (birthdayValue is DateTime) {
                birthdayDate = birthdayValue;
              }
              if (birthdayDate != null &&
                  now.month == birthdayDate.month &&
                  now.day == birthdayDate.day) {
                print('Geburtstag erfüllt!');
                await supabase.from('user_achievements').insert({
                  'user_id': user.id,
                  'achievement_id': id,
                  'unlocked_at': DateTime.now().toIso8601String(),
                });
                _logUnlock(id, user.id);
              }
            }
            //Beta User
            if (type == 'is_beta_user') {
              final betauser = userdata['beta_user'];
              if (betauser == true) {
                print('user ist Beta Uuser');
                await supabase.from('user_achievements').insert({
                  'user_id': user.id,
                  'achievement_id': id,
                  'unlocked_at': DateTime.now().toIso8601String(),
                });
                _logUnlock(id, user.id);
              }
            }
          // First User
          /* TODO :
            if (type == 'user_number') {
              final usernumber = userdata['id'].int.tryParse();
              if (usernumber < 70) {
                print('user ist unter den ersten 70 usern');
                await supabase.from('user_achievements').insert({
                  'user_id': user.id,
                  'achievement_id': id,
                  'unlocked_at': DateTime.now().toIso8601String(),
                });
                _logUnlock(id, user.id);
              }
            }
*/
          case 'unique_count':
          case 'combined':
        }
      }
    }
  }

  //---------------------------------
  //---------Hilfsfunktionen---------
  //---------------------------------
  void _logUnlock(int id, String userId) {
    print('Achievement $id mit user id: $userId erfolgreich freigeschaltet');
  }
}

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

            final value = req['value'];
            final operator = req['operator'] ?? 'greater_equal';

            print('[$id] Prüfe type=$type operator=$operator value=$value');

            // Friday the 13th
            if (type == 'is_friday_13th') {
              if (now.weekday == 5 && now.day == 13) {
                print('Friday the 13th erfüllt!');
                await _logUnlock(id, user.id);
                continue;
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
                await _logUnlock(id, user.id);
                continue;
              }
            }
            //Beta User
            if (type == 'is_beta_user') {
              final betauser = userdata['beta_user'];
              if (betauser == true) {
                print('user ist Beta Uuser');
                await _logUnlock(id, user.id);
                continue;
              }
            }

            // Einfacher vergleich

            final num? actualValue = _getActualValue(type, userdata);
            if (actualValue == null) {
              print('[$id] Kein actualValue für type=$type = überspringen');
              continue;
            }

            final conditionMet = switch (operator) {
              'less_equal' => actualValue <= value,
              'less_than' => actualValue < value,
              'equals' => actualValue == value,
              'greater_equal' => actualValue >= value,
              'greater_than' => actualValue > value,
              _ => false,
            };
            print('[$id] actualValue=$actualValue conditionMet=$conditionMet');

            if (conditionMet) {
              await _logUnlock(id, user.id);
            }

          case 'unique_count':
          case 'combined':
        }
      }
    }
  }

  //---------------------------------
  //---------Hilfsfunktionen---------
  //---------------------------------

  //Debug Ausgabe und Supabase eintragung
  Future<void> _logUnlock(int id, String userId) async {
    await supabase.from('user_achievements').insert({
      'user_id': userId,
      'achievement_id': id,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
    print('Achievement $id mit user id: $userId erfolgreich freigeschaltet');
  }

  //
  num? _getActualValue(String type, Map<String, dynamic> userdata) {
    switch (type) {
      case 'user_number':
        return userdata['user_number'];
      case 'age':
        final birthdayValue = userdata['birthdate'];
        if (birthdayValue == null) return null;

        final birthDate = DateTime.tryParse(birthdayValue);
        if (birthDate == null) return null;

        final now = DateTime.now();
        int age = now.year - birthDate.year;

        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }

        return age;

      case 'current_hour':
        return DateTime.now().hour;
      default:
        return null;
    }
  }
}

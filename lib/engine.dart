//engine.dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:io';

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
            // Mathias mode
            if (type == 'light_mode_days') {
              final prefs = await SharedPreferences.getInstance();
              final tageSeitThemeChange =
                  prefs.getInt('tageSeitThemeChange') ?? 0;
              final currentTheme =
                  prefs.getString('currentThemeMode') ?? 'dark';
              if (tageSeitThemeChange <= 30 && currentTheme == 'light') {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // Dark Mode achievment (dark Side oder so)
            if (type == 'dark_mode_days') {
              final prefs = await SharedPreferences.getInstance();
              final tageSeitThemeChange =
                  prefs.getInt('tageSeitThemeChange') ?? 0;
              final currentTheme =
                  prefs.getString('currentThemeMode') ?? 'dark';
              if (tageSeitThemeChange <= 30 && currentTheme == 'dark') {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // Palimdrom day
            if (type == 'is_palindrome_date') {
              final dateString =
                  '${now.day.toString().padLeft(2, '0')}'
                  '${now.month.toString().padLeft(2, '0')}'
                  '${now.year}';

              final reversed = dateString.split('').reversed.join();

              if (dateString == reversed) {
                await _logUnlock(id, user.id);
                continue;
              }
            }

            // The Right Side Doe
            if (type == 'operating_system') {
              final osName = Platform.operatingSystem.toLowerCase();
              final targetOs = req['value'].toString().toLowerCase();

              if (osName == targetOs) {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // New Year
            if (type == 'is_new_year') {
              if (now.month == 1 && now.day == 1) {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // Christmas
            if (type == 'is_christmas') {
              if (now.month == 12 && now.day == 24) {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // Night Coder
            if (type == 'night_coder_hours') {
              if (now.hour >= 2 && now.hour < 4) {
                await _logUnlock(id, user.id);
                continue;
              }
            }
            // Einfacher generischervergleich
            final num? actualValue = await _getActualValue(type, userdata);
            if (actualValue == null) {
              print('[$id] Kein actualValue für type=$type = überspringen');
              continue;
            }

            final num minValue = req['min_value'] ?? 0;

            final conditionMet = switch (operator) {
              'less_equal' => actualValue <= value && actualValue >= minValue,
              'less_than' => actualValue < value && actualValue >= minValue,
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

  // Ermittelt userdaten für genersichen algorytmohs
  Future<num?> _getActualValue(
    String type,
    Map<String, dynamic> userdata,
  ) async {
    switch (type) {
      // Geburts Jahr
      case 'birth_year':
        final birthdayValue = userdata['birthdate'];
        if (birthdayValue == null) return null;
        return DateTime.tryParse(birthdayValue)?.year;

      // Der wie vielte user
      case 'user_number':
        return userdata['user_number'];

      // Geburstag
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
      // Aktuell stunde
      case 'current_hour':
        return DateTime.now().hour;

      // Akkustand
      case 'battery_percent':
        final battery = Battery();
        return await battery.batteryLevel;

      default:
        return null;
    }
  }
}

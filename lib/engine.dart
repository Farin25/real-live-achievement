//engine.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:io';
import 'services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AchievementEngine {
  final supabase = Supabase.instance.client;

  Future<void> run() async {
    try {
      final ping = await InternetAddress.lookup('achieveirl.de');
      if (ping.isEmpty || ping.first.rawAddress.isEmpty) return;
    } on SocketException {
      dLog('[Engine] nicht gestartet Kein Internet');
      return;
    }
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final achievements = await supabase.from('achievements').select();

      final unlocked = await supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', user.id);

      final userdata = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userdata == null) return;
      final unlockedIds = unlocked.map((u) => u['achievement_id']).toSet();

      for (final achievement in achievements) {
        final id = achievement['id'];
        final requirement = achievement['requirement'];

        if (unlockedIds.contains(id)) {
          continue;
        } else {
          if (requirement == null) continue;

          Map<String, dynamic> req;
          try {
            req = requirement is String
                ? Map<String, dynamic>.from(jsonDecode(requirement))
                : Map<String, dynamic>.from(requirement);
          } catch (e) {
            if (kDebugMode) {
              print('$id Ungültighes requierement-Format: $requirement');
            }

            continue;
          }

          final mechanism = req['mechanism'];

          switch (mechanism) {
            case 'simple_threshold':
              final type = req['type'];
              final now = DateTime.now();

              final value = req['value'];
              final operator = req['operator'] ?? 'greater_equal';

              // Friday the 13th
              if (type == 'is_friday_13th') {
                if (now.weekday == 5 && now.day == 13) {
                  if (kDebugMode) print('Friday the 13th erfüllt!');
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
                  if (kDebugMode) print('Geburtstag erfüllt!');
                  await _logUnlock(id, user.id);
                  continue;
                }
              }
              //Beta User
              if (type == 'is_beta_user') {
                final betauser = userdata['beta_user'];
                if (betauser == true) {
                  if (kDebugMode) print('user ist Beta Uuser');
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
                    prefs.getString('currentThemeMode') ??
                    'dark'; // ← getString!
                if (tageSeitThemeChange >= 30 && currentTheme == 'light') {
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
                if (tageSeitThemeChange >= 30 && currentTheme == 'dark') {
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
              //Halloween
              if (type == 'is_halloween') {
                if (now.month == 10 && now.day == 31) {
                  await _logUnlock(id, user.id);
                  continue;
                }
              }
              // Leap year
              if (type == 'is_leap_day') {
                if (now.month == 2 && now.day == 29) {
                  await _logUnlock(id, user.id);
                  continue;
                }
              }
              // Pi Day
              if (type == 'is_PI_day') {
                if (now.month == 3 && now.day == 14) {
                  await _logUnlock(id, user.id);
                  continue;
                }
              }
              // EU Länder

              // Visited city: check against visited_citys list
              if (type == 'visited_city') {
                final prefs = await SharedPreferences.getInstance();
                final List<String> visitedCitys = List<String>.from(
                  jsonDecode(prefs.getString('visited_citys') ?? '[]'),
                );
                final cityValue = value.toString().toLowerCase();
                if (visitedCitys.any((c) => c.toLowerCase() == cityValue)) {
                  await _logUnlock(id, user.id);
                }
                continue;
              }
              // Einfacher generischer verglich für Strings
              final String? actualString = await _getActualValueString(
                type,
                userdata,
              );
              if (actualString != null) {
                if (actualString == value.toString().toLowerCase()) {
                  await _logUnlock(id, user.id);
                }
                continue;
              }

              // Einfacher generischervergleich für int
              final num? actualValue = await _getActualValue(type, userdata);
              if (actualValue == null) {
                if (kDebugMode) {
                  print('[$id] Kein actualValue für type=$type = überspringen');
                }
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

              if (kDebugMode) {
                print(
                  '[$id] actualValue=$actualValue conditionMet=$conditionMet',
                );
              }

              if (conditionMet) {
                await _logUnlock(id, user.id);
              }

            case 'unique_count':
              final type = req['type'];
              final value = req['value'];

              final num? count = await _getActualValue(type, userdata);
              if (count != null && count >= value) {
                await _logUnlock(id, user.id);
              }

            case 'combined':
              final conditions = req['conditions'] as List;
              bool allMet = true;

              for (final condition in conditions) {
                final type = condition['type'];
                final value = condition['value'];
                final operator = condition['operator'] ?? 'greater_equal';

                //
                final num? actual = await _getActualValue(type, userdata);
                if (actual == null) {
                  allMet = false;
                  break;
                }

                final conditionMet = switch (operator) {
                  'less_equal' => actual <= value,
                  'less_than' => actual < value,
                  'equals' => actual == value,
                  'greater_equal' => actual >= value,
                  'greater_than' => actual > value,
                  _ => false,
                };

                if (!conditionMet) {
                  allMet = false;
                  break;
                }
              }

              if (allMet) await _logUnlock(id, user.id);
          }
        }
      }
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      if (kDebugMode) print('[Engine] Fehler: $e');
    }
  }

  //---------------------------------
  //---------Hilfsfunktionen---------
  //---------------------------------

  //unlock prozess in supabase
  Future<void> _logUnlock(int id, String userId) async {
    try {
      await supabase.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': id,
        'unlocked_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print(
          'Achievement $id mit user id: $userId erfolgreich freigeschaltet',
        );
      }

      await _pushnotification(id);
    } on SocketException {
      if (kDebugMode) print('[Engine]Keine Inernetverbindung');
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      if (kDebugMode) print('[_logUnlock] Fehler bei Achievement $id: $e');
    }
  }

  // Ermittelt int userdaten für genersichen algorytmohs
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
      //EU Länder
      case 'eu_countries_visited':
        final prefs = await SharedPreferences.getInstance();
        final List<String> visitedCountries = List<String>.from(
          jsonDecode(prefs.getString('visited_countries') ?? '[]'),
        );
        const euCodes = [
          'DE',
          'FR',
          'IT',
          'ES',
          'PL',
          'NL',
          'BE',
          'SE',
          'AT',
          'DK',
          'FI',
          'IE',
          'PT',
          'CZ',
          'RO',
          'HU',
          'SK',
          'BG',
          'HR',
          'SI',
          'LT',
          'LV',
          'EE',
          'CY',
          'LU',
          'MT',
        ];
        return visitedCountries.where((c) => euCodes.contains(c)).length;
      // Aktuell stunde
      case 'current_hour':
        return DateTime.now().hour;

      // Akkustand
      case 'battery_percent':
        final battery = Battery();
        return await battery.batteryLevel;

      // Besuchte Länder
      case 'countries_visited':
        final prefs = await SharedPreferences.getInstance();
        final List<String> visited = List<String>.from(
          jsonDecode(prefs.getString('visited_countries') ?? '[]'),
        );

        return visited.length;

      // Besuchte Städte
      case 'citys_visited':
        final prefs = await SharedPreferences.getInstance();
        final List<String> visited = List<String>.from(
          jsonDecode(prefs.getString('visited_citys') ?? '[]'),
        );

        return visited.length;

      case String t when t.startsWith('cities_visited_'):
        final countryCode = t.split('_').last;
        final prefs = await SharedPreferences.getInstance();
        final List<String> visited = List<String>.from(
          jsonDecode(prefs.getString('visited_citys_$countryCode') ?? '[]'),
        );
        return visited.length;

      default:
        return null;
    }
  }

  // Ermittelt Userdaten als String für generischen Algorythmos
  Future<String?> _getActualValueString(
    String type,
    Map<String, dynamic> userdata,
  ) async {
    switch (type) {
      case 'operating_system':
        return Platform.operatingSystem.toLowerCase();

      case 'visited_city':
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('current_city')?.toLowerCase();

      case 'country':
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('current_country_code')?.toLowerCase();

      default:
        return null;
    }
  }

  Future<void> _pushnotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('pushNewAchievement') ?? true;
    if (!pushEnabled) return;

    final achievement = await supabase
        .from('achievements')
        .select('name, description')
        .eq('id', id)
        .maybeSingle();

    if (achievement == null) return;
    final String name = achievement['name'];
    final String description = achievement['description'];

    await AppServices.pushAchievementNotification(
      achievementId: id.toString(),
      title: '$name Freigeschaltet',
      body: '$description :)',
    );
  }
}

// engine_helpers.dart
import 'dart:async';
import 'dart:io';
import 'engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'services.dart';

class EngineRunner {
  static EngineRunner? instance;

  final int runEngineMinutes;
  Timer? _timer;

  EngineRunner._(this.runEngineMinutes);

  static Future<EngineRunner> create() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('engineTimerMinutes') ?? 10;
    instance = EngineRunner._(minutes);

    return instance!;
  }

  void startWatching() {
    // _watchLocation(); Auskommentiert weil kommt später

    //_watchApp();

    _watctchTime();

    //_WatchSteps(); Auskommentiert weil kommt später
  }

  //void _watchApp() {
  //Notifier().addListener(() {
  //    runEngine();
  //  });
  // }

  void _watctchTime() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(minutes: runEngineMinutes), (timer) {
      dLog('Der Timer ist abgelaufen');
      runEngine();
    });
  }

  void restartTimer() async {
    _timer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('engineTimerMinutes') ?? 10;

    _timer = Timer.periodic(Duration(minutes: minutes), (timer) {
      dLog('Timer abgelaufen engine wird gestartet');
      runEngine();
    });
  }
}

//startet die engine
void runEngine() {
  AchievementEngine().run();
}

//-----------------------------------------------------------------------
//----------Engine Helpers -  Stellt die werte für die engine bereit-----
//-----------------------------------------------------------------------
class EngineHelpers {
  EngineHelpers() {
    updateThemeDays();
    updateLocation();
  }

  // datum seit dem Januar 1970, 00:00:00 UTC in tage umwandeln für thememdoe
  Future<void> updateThemeDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Timestamp laden
      int? timestamp = prefs.getInt('themeChangeTime');

      if (timestamp != null) {
        DateTime lastChange = DateTime.fromMillisecondsSinceEpoch(timestamp);
        int tageSeitLetztemChange = DateTime.now()
            .difference(lastChange)
            .inDays;

        // Tage speichern
        await prefs.setInt('tageSeitThemeChange', tageSeitLetztemChange);
      }
    } catch (e) {
      dLog('[Themodedays] Fehler: $e');
      Sentry.captureException(e);
    }
  }
  //---------------------------------
  //------------Location Dienste-----
  //---------------------------------

  Future<void> updateLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      dLog('[Location] Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        dLog('[Location] ABBRUCH: Location service deaktiviert: 350');
        showAppSnackBar('Location Services Deaktiviert! Error: 350');
        return;
      }

      permission = await Geolocator.checkPermission();
      dLog('[Location] Permission: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        dLog('[Location] Permission nach Request: $permission');
        if (permission == LocationPermission.denied) {
          dLog('[Location] ABBRUCH: Permission verweigert: 351');
          showAppSnackBar('Keine Standort Berechtigung! Error: 351');
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          dLog('[Location] ABBRUCH: Permission dauerhaft verweigert: 352');
          showAppSnackBar(
            'Standort Berechtigung dauerhaft verweigert! Error: 352',
          );
          return;
        }
      }

      dLog('[Location] Hole Position...');
      final position = await Geolocator.getCurrentPosition();
      dLog('[Location] Position: ${position.latitude}, ${position.longitude}');

      // In Stadt und Land wechseln
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.first;
      dLog(
        '[Location] locality="${placemark.locality}" subLocality="${placemark.subLocality}" adminArea="${placemark.administrativeArea}"',
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('current_city', placemark.locality ?? '');
      await prefs.setString('current_country', placemark.country ?? '');
      await prefs.setString(
        'current_country_code',
        placemark.isoCountryCode ?? '',
      );
      await prefs.setDouble('current_latitude', position.latitude);
      await prefs.setDouble('current_longitude', position.longitude);

      //Ländeer Liste
      final List<String> visitedCountries = List<String>.from(
        jsonDecode(prefs.getString('visited_countries') ?? '[]'),
      );
      final countryCode = placemark.isoCountryCode ?? '';

      if (countryCode.isNotEmpty && !visitedCountries.contains(countryCode)) {
        visitedCountries.add(countryCode);
        await prefs.setString(
          'visited_countries',
          jsonEncode(visitedCountries),
        );
      }

      // Städte Liste
      final List<String> visitedCitys = List<String>.from(
        jsonDecode(prefs.getString('visited_citys') ?? '[]'),
      );
      final cityCode = placemark.locality ?? '';

      if (cityCode.isNotEmpty && !visitedCitys.contains(cityCode)) {
        visitedCitys.add(cityCode);
        await prefs.setString('visited_citys', jsonEncode(visitedCitys));
      }

      if (countryCode.isNotEmpty) {
        final List<String> countryVisited = List<String>.from(
          jsonDecode(prefs.getString('visited_citys_$countryCode') ?? '[]'),
        );
        if (cityCode.isNotEmpty && !countryVisited.contains(cityCode)) {
          countryVisited.add(cityCode);
          await prefs.setString(
            'visited_citys_$countryCode',
            jsonEncode(countryVisited),
          );
        }
      }
    } catch (e, stack) {
      dLog('[updateLocation] Fehler: $e $stack');
      Sentry.captureException(e, stackTrace: stack);
    }
  }
}
//---------------------------------
//------------BG Dienst------------
//---------------------------------

@pragma('vm:entry-point')
void backgroundTaskCallback() {
  Workmanager().executeTask((task, inputData) async {
    dLog('[Background] Task gestartet: $task');

    try {
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      dLog('[Background] Supabase initialisiert');

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      await AchievementEngine().run();

      dLog('[Background] Engine erfolgreich ausgeführt');

      return Future.value(true);
    } on SocketException {
      dLog('Netzwerfehler');

      return Future.value(false);
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      dLog('[Background] Fehler: $e');
      return Future.value(false);
    }
  });
}

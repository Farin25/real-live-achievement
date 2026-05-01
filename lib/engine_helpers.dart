// engine_helpers.dart
import 'dart:async';
import 'engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

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
      print('Der Timer ist abgelaufen');
      runEngine();
    });
  }

  void restartTimer() async {
    _timer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('engineTimerMinutes') ?? 10;

    _timer = Timer.periodic(Duration(minutes: minutes), (timer) {
      print('Timer abgelaufen engine wird gestartet');
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
    final prefs = await SharedPreferences.getInstance();

    // Timestamp laden
    int? timestamp = prefs.getInt('themeChangeTime');

    if (timestamp != null) {
      DateTime lastChange = DateTime.fromMillisecondsSinceEpoch(timestamp);
      int tageSeitLetztemChange = DateTime.now().difference(lastChange).inDays;

      // Tage speichern
      await prefs.setInt('tageSeitThemeChange', tageSeitLetztemChange);
    }
  }
  //---------------------------------
  //------------Location Dienste-----
  //---------------------------------

  Future<void> updateLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('[Location] Service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print('[Location] ABBRUCH: Location service deaktiviert');
      return;
    }

    permission = await Geolocator.checkPermission();
    print('[Location] Permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('[Location] Permission nach Request: $permission');
      if (permission == LocationPermission.denied) {
        print('[Location] ABBRUCH: Permission verweigert');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('[Location] ABBRUCH: Permission dauerhaft verweigert — in Android-Einstellungen freigeben');
      return;
    }

    print('[Location] Hole Position...');
    final position = await Geolocator.getCurrentPosition();
    print('[Location] Position: ${position.latitude}, ${position.longitude}');

    // In Stadt und Land wechseln
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks.first;
    print('[Location] locality="${placemark.locality}" subLocality="${placemark.subLocality}" adminArea="${placemark.administrativeArea}"');
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
      await prefs.setString('visited_countries', jsonEncode(visitedCountries));
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
  }
}

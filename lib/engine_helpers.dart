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

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();

    // In Stadt und Land wechseln
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    // In Chache speichern
    final placemark = placemarks.first;
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
    final List<String> visitedCountries = jsonDecode(
      prefs.getString('visited_countries') ?? '[]',
    );
    final countryCode = placemark.isoCountryCode ?? '';

    if (countryCode.isNotEmpty && !visitedCountries.contains(countryCode)) {
      visitedCountries.add(countryCode);
      await prefs.setString('visited_countries', jsonEncode(visitedCountries));
    }

    // Städte Liste
    final List<String> visitedCitys = jsonDecode(
      prefs.getString('visited_citys') ?? '[]',
    );
    final cityCode = placemark.locality ?? '';

    if (cityCode.isNotEmpty && !visitedCitys.contains(cityCode)) {
      visitedCitys.add(cityCode);
      await prefs.setString('visited_citys', jsonEncode(visitedCitys));
    }
  }
}

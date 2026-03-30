// engine_helpers.dart
import 'dart:async';
import 'engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EngineRunner {
  final int runEngineMinutes;
  Timer? _timer;

  EngineRunner._(this.runEngineMinutes);

  static Future<EngineRunner> create() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('engineTimerMinutes') ?? 5;

    return EngineRunner._(minutes);
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
}

//startet die engine
void runEngine() {
  AchievementEngine();
}

//-----------------------------------------------------------------------
//----------Engine Helpers -  Stellt die werte für die engine bereit-----
//-----------------------------------------------------------------------
class EngineHelpers {
  EngineHelpers() {
    updateThemeDays();
  }

  // datum siet dem Januar 1970, 00:00:00 UTC in tage umwandeln für thememdoe
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
}

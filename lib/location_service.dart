// location_service.dart

import 'package:geolocator/geolocator.dart';  // GPS Package
import 'package:geocoding/geocoding.dart';     // Für Land/Stadt aus Koordinaten
import 'package:shared_preferences/shared_preferences.dart'; // Lokaler Cache
import 'dart:async';

class LocationService {

  // -------------------------------------------
  // SCHRITT 1: Berechtigungen prüfen & anfragen
  // -------------------------------------------
  // Diese Funktion muss IMMER zuerst aufgerufen werden
  // bevor wir GPS nutzen dürfen
  static Future<bool> requestPermission() async {

    // Ist GPS auf dem Gerät überhaupt aktiviert?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS ist ausgeschaltet");
      return false; // false = kein GPS verfügbar
    }

    // Hat die App die Berechtigung GPS zu nutzen?
    LocationPermission permission = await Geolocator.checkPermission();

    // Wenn noch keine Berechtigung → Nutzer fragen
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // Nutzer hat abgelehnt
      if (permission == LocationPermission.denied) {
        print("GPS Berechtigung abgelehnt");
        return false;
      }
    }

    // Nutzer hat dauerhaft abgelehnt (in App-Einstellungen gesperrt)
    if (permission == LocationPermission.deniedForever) {
      print("GPS dauerhaft gesperrt");
      return false;
    }

    return true; // Alles gut, GPS darf genutzt werden
  }


  // -------------------------------------------
  // SCHRITT 2: Aktuelle Position holen
  // -------------------------------------------
  // location_service.dart - getCurrentPosition() absichern
static Future<Position?> getCurrentPosition() async {
  final hasPermission = await requestPermission();
  if (!hasPermission) return null;

  try {
    final position = await Geolocator.getCurrentPosition(
      // Timeout hinzufügen! Ohne Timeout wartet GPS ewig
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10), // Nach 10s aufgeben
    );

    await _cachePosition(position);
    return position;

  } on TimeoutException {
    print("GPS Timeout - nutze Cache");
    return getCachedPosition(); // Fallback auf Cache
  } catch (e) {
    print("Fehler beim GPS abrufen: $e");
    return getCachedPosition(); // Fallback auf Cache
  }
}


  // -------------------------------------------
  // SCHRITT 3: Position cachen (lokal speichern)
  // -------------------------------------------
  // Das _ am Anfang bedeutet: private Funktion
  // = nur innerhalb dieser Datei aufrufbar
  static Future<void> _cachePosition(Position position) async {
    final prefs = await SharedPreferences.getInstance();

    // Wir speichern Latitude und Longitude als Double (Kommazahl)
    await prefs.setDouble('last_lat', position.latitude);
    await prefs.setDouble('last_lng', position.longitude);
    
    // Zeitstempel speichern - wann wurde die Position gespeichert?
    await prefs.setInt(
      'last_location_time',
      DateTime.now().millisecondsSinceEpoch, // Zeit als Zahl in Millisekunden
    );
  }


  // -------------------------------------------
  // SCHRITT 4: Gecachte Position laden
  // -------------------------------------------
  // Wenn kein Internet/GPS → letzte bekannte Position nutzen
  static Future<Position?> getCachedPosition() async {
    final prefs = await SharedPreferences.getInstance();

    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_lng');

    // Wenn nichts gecacht → null zurückgeben
    if (lat == null || lng == null) return null;

    // Position-Objekt manuell erstellen aus gespeicherten Werten
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }


  // -------------------------------------------
  // SCHRITT 5: Distanz berechnen
  // -------------------------------------------
  // Berechnet wie weit zwei GPS-Punkte voneinander entfernt sind
  static double calculateDistance({
    required double fromLat,  // Start Latitude
    required double fromLng,  // Start Longitude
    required double toLat,    // Ziel Latitude
    required double toLng,    // Ziel Longitude
  }) {
    // Geolocator hat eine eingebaute Funktion dafür
    // Ergebnis ist in Metern → wir rechnen in km um
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000; // Meter → Kilometer
  }


  // -------------------------------------------
  // SCHRITT 6: Distanz von Zuhause berechnen
  // -------------------------------------------
  static Future<double?> getDistanceFromHome() async {
    final prefs = await SharedPreferences.getInstance();

    // Zuhause-Position aus Cache holen
    final homeLat = prefs.getDouble('home_lat');
    final homeLng = prefs.getDouble('home_lng');

    // Wenn noch kein Zuhause gespeichert → null
    if (homeLat == null || homeLng == null) return null;

    // Aktuelle Position holen
    final current = await getCurrentPosition();
    if (current == null) return null;

    // Distanz berechnen und zurückgeben
    return calculateDistance(
      fromLat: homeLat,
      fromLng: homeLng,
      toLat: current.latitude,
      toLng: current.longitude,
    );
  }


  // -------------------------------------------
  // SCHRITT 7: Aktuelles Land herausfinden
  // -------------------------------------------
  // Reverse Geocoding = GPS Koordinaten → Adresse/Land
  static Future<String?> getCurrentCountry() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    try {
      // placemarkFromCoordinates gibt eine Liste von Orten zurück
      // first = der erste (genaueste) Eintrag
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // isoCountryCode = Ländercode z.B. "DE", "FR", "US"
      return placemarks.first.isoCountryCode;

    } catch (e) {
      print("Fehler beim Reverse Geocoding: $e");
      return null;
    }
  }


  // -------------------------------------------
  // SCHRITT 8: Aktuelle Stadt herausfinden
  // -------------------------------------------
  static Future<String?> getCurrentCity() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // locality = Stadtname
      return placemarks.first.locality;

    } catch (e) {
      print("Fehler beim Stadt ermitteln: $e");
      return null;
    }
  }
}
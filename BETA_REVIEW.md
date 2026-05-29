# Up Mark — Beta Review Report
**Datum:** 27.05.2026  
**Reviewer:** Claude Sonnet 4.6 (Claude Code)  
**Package:** `de.farin.reallifeachievements`  
**Backend:** Supabase  
**Ziel:** Beta-Release als APK (direkte Verteilung)  

---

## Inhaltsverzeichnis

1. [Bestandsaufnahme (Phase 1)](#phase-1-bestandsaufnahme)
2. [Security Review Code (Phase 2)](#phase-2-security-review-code)
3. [Supabase / Backend Security (Phase 3)](#phase-3-supabase--backend-security)
4. [Code Quality & Bugs (Phase 4)](#phase-4-code-quality--bugs)
5. [UI / UX (Phase 5)](#phase-5-ui--ux)
6. [Beta-APK Release Vorbereitung (Phase 6)](#phase-6-beta-apk-release-vorbereitung)
7. [**Final Output — Priorisierte Findings**](#final-output--priorisierte-findings)

---

## Phase 1: Bestandsaufnahme

### Stack & Versionen

| Komponente | Version |
|---|---|
| Flutter | 3.41.2 |
| Dart SDK (deklariert) | ^3.10.8 |
| Supabase Flutter | ^2.12.0 |

### Projektstruktur

Flat-File-Architektur — alle ~10 Dart-Dateien liegen direkt in `lib/`, keine Feature-Ordner, keine Schichten.

| Datei | Inhalt |
|---|---|
| `main.dart` | App-Einstieg, `AuthGate`, `SplashWrapper` |
| `engine.dart` | Achievement-Bewertungslogik |
| `engine_helpers.dart` | Standort-Tracking, WorkManager-Background-Task, `EngineRunner`-Timer |
| `services.dart` | Notifications, Loading-Screens, Navbar, Snackbar, SharedPrefs-Cache |
| `home.dart` | News-Feed (letzte freigeschaltete Achievements) |
| `achievments.dart` | Achievement-Übersicht mit Grid |
| `login.dart` | Login + Signup |
| `acount.dart` | Account-Verwaltung + Löschung |
| `settings.dart` | Alle Settings-Seiten (Design, Notifications, Erweitert, About) |
| `social.dart` | Placeholder-Seite, noch leer |
| `user_SessionManager.dart` | Session-Init, Logout |

Daneben: `settingsV2.dart.backup` — Backup-Datei liegt im `lib/`-Verzeichnis.

### State Management & Routing

- **State Management:** Kein dediziertes System — alles über `setState()`.  
  `flutter_riverpod: ^3.2.1` ist deklariert, wird aber **nirgends importiert oder genutzt**.
- **Routing:** Kein `go_router` in Verwendung — Navigation läuft über `Navigator.push()`.  
  `go_router: ^17.1.0` ist deklariert aber **nirgends genutzt**.
- **Auth-Flow:** Stream-basierter `AuthGate` über `Supabase.instance.client.auth.onAuthStateChange`.

### Nicht genutzte Dependencies

`flutter_riverpod`, `go_router`, `webview_flutter`, `health`, `app_links` — alle in `pubspec.yaml` deklariert, kein Importbefund im Code.

### Typos im Projektnamen

- `achievments.dart` (fehlt ein 'e')
- `acount.dart` (fehlt ein 'c')
- Inkonsistenz: `pubspec.yaml` zeigt `version: 1.0.0+1`, `AppConfig` in `settings.dart` zeigt `"BETA 0.5(dev)"`

---

## Phase 2: Security Review (Code)

### 1. Hardcoded Secrets / Credentials

**BLOCKER — `.env` als Flutter-Asset gebündelt**

`pubspec.yaml` Zeile 88:
```yaml
assets:
  - .env
```

Die `.env` mit `SUPABASE_URL` und `SUPABASE_ANON_KEY` ist als Asset deklariert und landet unkomprimiert in der APK (`build/flutter_assets/.env`). Jeder User kann mit `unzip app.apk` die Credentials im Klartext lesen — kein Reverse-Engineering nötig.

### 2. .gitignore

Die `.gitignore` ist insgesamt ordentlich:

| Eintrag | Status |
|---|---|
| `*.env` — schließt `.env` aus | ✓ korrekt |
| `android/key.properties` | ✓ korrekt |
| `**/*.jks` | ✓ korrekt |

**Lücke:** `**/*.keystore` fehlt — wenn der Keystore mit `.keystore`-Endung erstellt wird, wird er nicht ignoriert.

### 3. Token Storage

Kein Problem. `supabase_flutter` nutzt seit v2.x intern `flutter_secure_storage` für Session-Management (Android Keystore). Was in `SharedPreferences` landet: `first_name`, `last_name`, `username`, `birthdate` — keine Tokens.

### 4. Logging

**MEDIUM — User-UUID in Debug-Logs**

`engine.dart` Zeile 284:
```dart
if (kDebugMode)
  print('Achievement $id mit user id: $userId erfolgreich freigeschaltet');
```

Durch `kDebugMode` im Release-Build inaktiv. Die `dLog()`-Funktion in `services.dart` schützt korrekt alle anderen Log-Ausgaben.

### 5. AndroidManifest.xml

| Aspekt | Befund |
|---|---|
| `usesCleartextTraffic` | Nicht gesetzt — alle Endpoints HTTPS ✓ |
| Permissions | Nur `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS` ✓ |
| `exported` Activities | Nur `MainActivity` mit `exported="true"` ✓ |

**LOW — Deep Link nutzt Custom Scheme statt App Links**

```xml
<data android:scheme="upmark" android:host="auth-callback"/>
```

Custom Schemes (`upmark://`) sind nicht verifizierbar. Eine andere App könnte denselben Scheme registrieren. Da aktuell nur Passwort-Login genutzt wird (keine Magic Links), ist das Risiko gering.

### 6. Release-Build mit Debug-Keystore

**BLOCKER — `android/app/build.gradle.kts` Zeile 38:**
```kotlin
signingConfig = signingConfigs.getByName("debug")  // TODO im Code
```

### 7. debugShowCheckedModeBanner

**BLOCKER — `main.dart` Zeile 53:**
```dart
debugShowCheckedModeBanner: true,  // Solange true bis final beta version
```
Überschreibt Flutter-Default. DEBUG-Banner erscheint auch im Release-APK.

### 8. Ungenutzte Dependencies

`go_router`, `flutter_riverpod`, `webview_flutter`, `health`, `app_links` erhöhen APK-Größe und Angriffsfläche ohne Mehrwert.

---

## Phase 3: Supabase / Backend Security

### Tabellen-Zugriff Übersicht

| Tabelle | Operationen vom Client |
|---|---|
| `profiles` | SELECT (eigenes Profil), UPDATE (eigenes Profil) |
| `achievements` | SELECT (alle, kein Filter) |
| `user_achievements` | SELECT (gefiltert auf eigene user_id), INSERT |
| `loading_funfacts` | SELECT (alle, kein Filter) |
| `achievement_suggestions` | Kein Zugriff — nur über Web-Formular |
| `planned_achievements` | Kein Zugriff |
| `friendships` | Kein Zugriff — Social-Seite ist Placeholder |

RPCs vom Client: `username_exists`, `reactivate_user_account`, `delete_user_account`

### 1. Clientseitige Achievement-Unlock-Logik

**HIGH — Gesamte Unlock-Entscheidung liegt beim Client**

Die `AchievementEngine` läuft komplett auf dem Gerät und schreibt das Ergebnis direkt in `user_achievements`:

```dart
// engine.dart:278
await supabase.from('user_achievements').insert({
  'user_id': userId,
  'achievement_id': id,
  'unlocked_at': DateTime.now().toIso8601String(),
});
```

Jeder authentifizierte User kann per HTTP-POST direkt beliebige `achievement_ids` eintragen, ohne die Engine-Logik zu durchlaufen — sofern keine RLS-Policy das verhindert.

### 2. RPC-Parameter `uid` statt `auth.uid()`

**HIGH — `delete_user_account` und `reactivate_user_account`:**

```dart
// acount.dart:265
await supabase.rpc('delete_user_account', params: {'uid': user.id});

// main.dart:165
await supabase.rpc('reactivate_user_account', params: {'uid': user.id});
```

Wenn die DB-Funktion intern den übergebenen `uid`-Parameter direkt nutzt, ohne gegen `auth.uid()` zu prüfen, könnte ein Angreifer eine beliebige UUID übergeben. **Muss in Supabase verifiziert werden.**

### 3. Fehlende UNIQUE-Constraint auf `user_achievements`

**MEDIUM — Race Condition möglich**

Das Schema zeigt keine `UNIQUE(user_id, achievement_id)`-Constraint. Außerdem ist `achievement_id` nullable. Wenn Foreground-Timer und WorkManager gleichzeitig laufen, können beide dasselbe Achievement inserieren — doppelte Einträge entstehen.

**Empfehlung für Supabase:** `UNIQUE(user_id, achievement_id)` + `achievement_id NOT NULL`

### 4. `profiles` UPDATE ohne Username-Check

**MEDIUM** — Beim Profil-Update (anders als beim Signup) wird `username_exists` nicht geprüft. Bei Konflikt gibt es nur ein generisches `'Fehler: $e'` ohne klaren Hinweis auf den Grund.

### 5. `friendships` — Schema-Auffälligkeiten

**MEDIUM:**
- `id` hat kein `DEFAULT` / `GENERATED ALWAYS`
- `status text` hat keinen `CHECK('pending','accepted','rejected')`-Constraint
- `created_at` ist nullable ohne `DEFAULT now()`

### 6. Account-Löschung — FK-Kette

**LOW — Soft-Delete Konzept vorhanden**, aber: ob bei Hard-Delete `user_achievements` und `friendships` per `CASCADE DELETE` bereinigt werden, ist im Client-Code nicht sichtbar. Muss in Supabase sichergestellt sein.

### 7. `achievement_suggestions` — DSGVO

**MEDIUM** — Tabelle speichert `email` + `submitter_name`. Kein Zugriff aus der App, aber: Datenschutzerklärung sollte Zweck und Löschroutine beschreiben. Der Link auf `legal.farin-langner.de/#ds-upmark` sollte aktuell und vollständig sein.

---

## Phase 4: Code Quality & Bugs

### flutter analyze — 9 Issues (alle "info")

| Datei | Zeile | Rule | Schwere |
|---|---|---|---|
| `engine.dart` | 199, 215, 284 | `curly_braces_in_flow_control_structures` | Style |
| `login.dart` | 455, 458 | `curly_braces_in_flow_control_structures` | Style |
| **`main.dart`** | **173, 191** | **`use_build_context_synchronously`** | **BUG** |
| `social.dart` | 4 | `use_key_in_widget_constructors` | Minor |
| `user_SessionManager.dart` | 1 | `file_names` | Style |

### 1. `use_build_context_synchronously` — Echter Bug

**HIGH — `main.dart` Zeile 164–175:**
```dart
await supabase.rpc('reactivate_user_account', ...);
if (!context.mounted) return;        // ← mounted check ✓
Navigator.pop(context);
await supabase.auth.signOut();       // ← async gap DANACH
showAppSnackBar(context, '...');     // ← kein mounted check mehr!
```

Nach `await supabase.auth.signOut()` kann der Widget-Tree bereits zerstört sein. `showAppSnackBar(context, ...)` mit ungültigem Context → Crash.

### 2. Memory Leak — `AccountPage` Controllers nie disposed

**MEDIUM — `acount.dart` Zeilen 31–34:**
```dart
final _firstNameController = TextEditingController();
final _lastNameController = TextEditingController();
final _usernameController = TextEditingController();
final _birthdateController = TextEditingController();
```

`AccountPage` hat **keine `dispose()` Methode**. Alle vier Controller bleiben beim Verlassen der Seite im Speicher.

### 3. Memory Leak — EngineRunner Timer ohne dispose

**MEDIUM** — `EngineRunner` hat kein `dispose()`. Bei Logout + Login wird eine neue Instanz erstellt, der alte `Timer.periodic` läuft weiter und löst doppelte Engine-Runs aus.

Außerdem: `runEngine()` startet `AchievementEngine().run()` als unawaited Future:
```dart
// engine_helpers.dart:68
void runEngine() {
  AchievementEngine().run();  // ← unawaited
}
```

### 4. Bug — Infinity Spinner bei kein-WLAN

**HIGH — `achievments.dart` Zeilen 56–67:**
```dart
if (achievementDownloadOverWifi &&
    connectivityResult != ConnectivityResult.wifi) {
  return;  // ← KEIN setState(() => _isLoading = false);
}
```

Standard-Einstellung ist `achievementDownloadOverWifi = true`. Bei Mobile Data oder Netzwerkfehler bleibt `_isLoading = true` → ewiger Spinner. Der `catch`-Block (Zeile 87–89) setzt `_isLoading` ebenfalls nicht zurück.

### 5. Bug — Notification-Einstellungen ohne Wirkung

**MEDIUM** — Notification-Toggles werden in `SharedPreferences` gespeichert, aber die Engine prüft sie nie:
```dart
// engine.dart:285
await _pushnotification(id);  // ← immer, keine Prüfung der Einstellungen
```

### 6. Bug — Supabase doppelt initialisiert im Background Task

**MEDIUM — `engine_helpers.dart` Zeile 202:**
```dart
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
```

Wenn WorkManager den Task im selben Prozess ausführt, wirft `Supabase.initialize()` eine Exception → Task gibt `false` zurück, Engine läuft nicht.

### 7. Bug — Pages werden bei Tab-Wechsel neu erstellt

**MEDIUM — `services.dart` Zeilen 274–279:**
```dart
Widget build(BuildContext context) {
  final pages = [
    NewsFeedPage1(),      // ← neue Instanz bei jedem setState
    AchievmentSeite(),
    ...
  ];
```

Scroll-Positionen und geladene Daten gehen beim Tab-Wechsel verloren.

### 8. Fehlende mounted-Checks nach await

**MEDIUM** — `setState` nach async ohne `if (!mounted) return`:

| Datei | Zeile | Kontext |
|---|---|---|
| `achievments.dart` | 51 | Nach `SharedPreferences.getInstance()` |
| `achievments.dart` | 82 | Nach zwei Supabase-Queries |
| `home.dart` | 52 | Nach `SharedPreferences.getInstance()` |
| `settings.dart` | 94 | Nach Supabase-Query |
| `acount.dart` | 47 | Nach Supabase-Query |

### 9. Weitere Code-Qualitäts-Issues

- `settingsV2.dart.backup` im aktiven `lib/`-Verzeichnis
- `_categoryColor()` in `home.dart` und `achievments.dart` identisch dupliziert
- Dateinamen verletzen Flutter-Konventionen (`user_SessionManager.dart`)

---

## Phase 5: UI / UX

### Loading / Error / Empty States — Übersicht

| Screen | Loading | Error State | Empty State |
|---|---|---|---|
| Home (Feed) | ✓ Spinner | Kein Feedback (silent fail) | ✓ schön gestaltet |
| Achievements | ✓ Spinner (Bug: bleibt hängen) | Kein Feedback | Kein dedizierter State |
| Settings (Profil) | ✓ Spinner | **Kein try/catch** | n.a. |
| Account | ✓ Spinner | Keine Meldung bei Ladefehler | n.a. |

`settings.dart` `_loadProfile()` hat keinen `try/catch` — bei Supabase-Fehler bleibt die Settings-Seite im ewigen Spinner.

### Tablet-Bug — Login ohne Formular

**HIGH — `login.dart` Zeilen 14–32:**
```dart
isSmallScreen
  ? Column([_Logo(), _FormContent(...)])   // Mobile: korrekt
  : Container(Row([Expanded(child: _Logo())]))  // Tablet: NUR Logo, kein Formular!
```

Auf Tablets (Breite > 600px) oder im Landscape-Modus ist kein Login möglich.

### Keyboard Overflow — AccountPage

**MEDIUM** — Logout- und Account-löschen-Buttons liegen außerhalb des scrollbaren `ListView`, in einem äußeren `Column`. Auf kleinen Phones können sie hinter der Tastatur verschwinden.

### Offline-Verhalten

**MEDIUM** — Connectivity wird nur in `achievments.dart` geprüft (mit Bug). In `home.dart`, `settings.dart`, `acount.dart` gibt es bei Offline silent fails ohne Benutzer-Feedback. Kein Offline-Banner.

### Dark/Light Mode — Inkonsistenz

**MEDIUM** — `LoadingScreen` und `LoadingScreenWolke` haben immer `backgroundColor: Colors.black` — ignorieren das Theme. Im Light-Mode entsteht ein harter Kontrast-Sprung beim Laden.

Alle anderen Komponenten (FeedCards, Achievement-Tiles, SnackBar) handhaben Dark/Light korrekt.

### Splash Screen — Zwei überlagernde Erlebnisse

**LOW** — Native Android-Splash → dann `SplashWrapper` für 3 Sekunden (wenn nicht eingeloggt). Zwei Splash-Erlebnisse hintereinander.

### Bildschirmgrößen

**LOW** — Nur die Login-Seite hat responsive Logik. Achievements-Grid nutzt fixen `crossAxisCount: 3` — auf sehr kleinen Phones (< 360px) schwer lesbar.

### Back-Button

Kein Problem. Standard `Navigator.push`-Backstack, kein `WillPopScope` nötig.

---

## Phase 6: Beta-APK Release Vorbereitung

### Versionierung

**MEDIUM** — Inkonsistente Versionen:
- `pubspec.yaml`: `1.0.0+1` (Flutter-Default, klingt nach Stable v1)
- `AppConfig.version`: `"BETA 0.5(dev)"`

Empfehlung: `0.5.0-beta+1` — dann `versionCode` bei jeder APK-Iteration erhöhen, sonst lehnt Android Updates ab.

### SDK-Versionen

| Parameter | Wert | Bewertung |
|---|---|---|
| `minSdk = 26` | Android 8.0 (2017) | ✓ Vernünftig, ~95% Geräte |
| `targetSdk` | 36 (Android 16) via Flutter Plugin | ✓ Aktuell |
| `compileSdk` | 36 via Flutter Plugin | ✓ Aktuell |

### Signing

**BLOCKER** — Kein `key.properties`, kein Keystore. Release-Build nutzt Debug-Signing.

### ProGuard / R8

**MEDIUM** — Keine `proguard-rules.pro` vorhanden, keine `minifyEnabled`-Konfiguration. Flutter aktiviert R8 für Release-Builds automatisch, aber explizite Regeln für `workmanager` und `supabase_flutter` könnten nötig werden.

### App Icon

**MEDIUM — `flutter_launcher_icons.yaml` Zeile 3:**
```yaml
image_path: "assets/icon/icon.png"  # Verzeichnis existiert nicht
```
Tatsächlicher Pfad: `assets/icon.png`. Ein erneutes `flutter pub run flutter_launcher_icons` würde mit "File not found" fehlschlagen.

Außerdem: keine adaptiven Icons für Android 8+ (`ic_launcher_foreground.xml`, `ic_launcher_background.xml`).

### Asset-Fehler in pubspec.yaml

**LOW** — `loading_2.png` zweimal deklariert, `loading_1.png` fehlt als expliziter Eintrag (wird aber durch `- assets/` abgedeckt).

### Icon-Dateigröße

**LOW** — `assets/icon.png` (383KB, 1024×1024) wird als Runtime-Asset ins APK gebündelt. Könnte für UI-Zwecke auf ~50–100KB optimiert werden.

### Crash Reporting

**HIGH** — Kein Sentry, Firebase Crashlytics, Bugsnag oder ähnliches. Beta-Crashes bleiben unsichtbar außer bei manuellen Meldungen.

### Beta-Tester Installation

**MEDIUM** — Beta-Programm-Seite erklärt die Anmeldung, aber nicht die APK-Installation. Beta-Tester stolpern über:
1. "Unbekannte Quellen" / "Install unknown apps" in Android Settings
2. Browser-Sicherheitswarnung beim Download
3. Play Protect Warnung beim Installieren

---

## Final Output — Priorisierte Findings

---

### BLOCKER — Muss vor Beta-Release behoben werden

| # | Kategorie | Datei | Beschreibung |
|---|---|---|---|
| B1 | Security | `pubspec.yaml:88` | `.env` als Flutter-Asset gebündelt → `SUPABASE_URL` und `SUPABASE_ANON_KEY` im Klartext in der APK. Jeder kann sie mit `unzip app.apk` lesen. |
| B2 | Release | `android/app/build.gradle.kts:38` | Release-Build mit Debug-Keystore signiert. Kein eigenes Signing-Setup. APKs mit verschiedenen Keys können nicht per Update ersetzt werden. |
| B3 | UI/Bug | `login.dart:25-31` | Auf Tablets / Landscape (Breite > 600px) wird nur das Logo gerendert — kein Formular, kein Login möglich. |
| B4 | Release | `main.dart:53` | `debugShowCheckedModeBanner: true` explizit gesetzt — überschreibt Flutter-Default, roter DEBUG-Banner erscheint auch im Release-APK. |

---

### HIGH — Sollte vor Beta behoben werden

| # | Kategorie | Datei | Beschreibung |
|---|---|---|---|
| H1 | Bug | `achievments.dart:63-67` | `_isLoading` wird nicht auf `false` gesetzt wenn WiFi-Check fehlschlägt oder Netzwerkfehler auftritt → ewiger Spinner auf dem Achievements-Tab. |
| H2 | Bug | `main.dart:172-175` | `use_build_context_synchronously`: `showAppSnackBar(context, ...)` nach `await supabase.auth.signOut()` ohne `mounted`-Check → möglicher Crash. |
| H3 | Security | `acount.dart:265`, `main.dart:165` | `delete_user_account` / `reactivate_user_account` RPC erhält `uid` als Parameter. Wenn die DB-Funktion diesen direkt nutzt statt `auth.uid()`, können fremde Accounts manipuliert werden. Muss in Supabase verifiziert werden. |
| H4 | Security | `engine.dart:278-281` | Gesamte Achievement-Unlock-Logik liegt client-seitig. Authentifizierte User können beliebige `achievement_ids` direkt per Supabase-API inserieren, wenn RLS das nicht verhindert. |
| H5 | Release | — | Kein Crash Reporting (Sentry / Firebase Crashlytics / Bugsnag). Beta-Crashes bleiben unsichtbar ohne manuelle Meldung. |

---

### MEDIUM — Kann nach Beta-Feedback kommen

| # | Kategorie | Datei | Beschreibung |
|---|---|---|---|
| M1 | Bug | `acount.dart:31-34` | 4 `TextEditingController` ohne `dispose()` — Memory Leak beim Verlassen der Account-Seite. |
| M2 | Bug | `engine_helpers.dart:13-65` | `EngineRunner` Timer hat kein `dispose()`. Bei Logout+Login bleiben alte Timer aktiv → doppelte Engine-Runs. |
| M3 | Bug | `services.dart:274-280` | Pages-Array in `build()` erstellt → bei Tab-Wechsel werden alle Pages neu instanziiert, Scroll-Position und Daten gehen verloren. |
| M4 | Bug | `engine.dart:285` vs. `settings.dart:402` | Notification-Einstellungen (Toggles in AppMessages) werden von der Engine nie gelesen — Notifications feuern immer. |
| M5 | Bug | `engine_helpers.dart:202` | `Supabase.initialize()` im Background Task ohne Already-Initialized-Check → Exception wenn Task im selben Prozess läuft. |
| M6 | Security | Schema: `user_achievements` | Kein `UNIQUE(user_id, achievement_id)` — Race Condition zwischen Foreground-Timer und WorkManager kann doppelte Achievement-Einträge erzeugen. Außerdem ist `achievement_id` nullable. |
| M7 | UI | `home.dart:113`, `achievments.dart:87` | Kein Error-State bei Netzwerkfehler — User sieht Empty-State ohne Fehlermeldung (silent fail). |
| M8 | Bug | `achievments.dart:51,82`, `home.dart:52`, `settings.dart:94`, `acount.dart:47` | Fehlende `if (!mounted) return`-Checks vor `setState` nach `await`. |
| M9 | UI | `services.dart:183,499` | Loading Screens immer `backgroundColor: Colors.black` — ignorieren Dark/Light Theme. Kontrast-Sprung im Light-Mode. |
| M10 | Release | `pubspec.yaml:19`, `settings.dart:14` | Versionsnummer inkonsistent: `1.0.0+1` vs. `"BETA 0.5(dev)"` im UI. `versionCode` muss bei jeder APK-Iteration erhöht werden. |
| M11 | Release | `flutter_launcher_icons.yaml:3` | Falscher Icon-Pfad: referenziert `assets/icon/icon.png`, tatsächlicher Pfad ist `assets/icon.png`. Erneutes `flutter pub run flutter_launcher_icons` würde fehlschlagen. |
| M12 | Release | `android/app/src/main/res/` | Keine Adaptive Icons (`ic_launcher_foreground.xml`, `ic_launcher_background.xml`) für Android 8+. |
| M13 | Release | Beta-Seite / README | Keine Installationsanleitung für Sideloading (Unbekannte Quellen, Play Protect Warnung). |
| M14 | Security | `.gitignore:21` | `**/*.jks` vorhanden, aber `**/*.keystore` fehlt — Keystores mit `.keystore`-Endung werden nicht ignoriert. |
| M15 | Security | Schema: `friendships` | `status text` ohne `CHECK`-Constraint (beliebige Strings möglich). `id` ohne `DEFAULT`/`GENERATED ALWAYS`. `created_at` nullable ohne `DEFAULT now()`. |
| M16 | Security/DSGVO | Schema: `achievement_suggestions` | Tabelle speichert `email` + `submitter_name` ohne sichtbare Löschroutine im App-Code. Datenschutzerklärung sollte Zweck und Retentionsdauer beschreiben. |

---

### NICE-TO-HAVE

| # | Kategorie | Datei | Beschreibung |
|---|---|---|---|
| N1 | Code | `pubspec.yaml` | 5 ungenutzte Dependencies: `go_router`, `flutter_riverpod`, `webview_flutter`, `health`, `app_links`. Erhöhen APK-Größe und Angriffsfläche. |
| N2 | Code | `home.dart:8`, `achievments.dart:21` | `_categoryColor()` in beiden Dateien identisch dupliziert — neue Kategorien müssen an zwei Stellen gepflegt werden. |
| N3 | Code | `lib/settingsV2.dart.backup` | Backup-Datei liegt im aktiven `lib/`-Verzeichnis. |
| N4 | Code | Diverse | Typos in Datei-/Paketnamen: `achievments` (fehlt 'e'), `acount` (fehlt 'c'), `real_live_achievments`. |
| N5 | Code | `engine.dart`, `login.dart` | `flutter analyze`: 9 Style-Issues — fehlende geschweifte Klammern, Dateinamen-Konventionen. |
| N6 | Release | `assets/icon.png` | `icon.png` (383KB, 1024×1024) wird als Runtime-Asset gebündelt. Für UI-Zwecke könnte das Bild auf ~50–100KB optimiert werden. |
| N7 | UI | `achievments.dart:303` | Fixer `crossAxisCount: 3` im Achievement-Grid — auf sehr kleinen Phones (< 360px Breite) schwer lesbar. |
| N8 | UI | `services.dart`, `main.dart` | Zwei Splash-Erlebnisse übereinander: nativer Android-Splash + Flutter `SplashWrapper` (3 Sekunden). |
| N9 | Code | `user_SessionManager.dart` | Dateiname verletzt Flutter Naming Conventions (sollte `user_session_manager.dart` sein). |
| N10 | Security | `AndroidManifest.xml:31-36` | Deep Link nutzt Custom Scheme (`upmark://`) statt Android App Links (HTTPS + Domain-Verifikation). |
| N11 | Security | `engine.dart:284` | User-UUID wird in Debug-Logs ausgegeben (`if (kDebugMode) print('...user id: $userId...')`). In Release inaktiv, aber für Produktion entfernen. |
| N12 | Release | `pubspec.yaml:84-86` | `loading_2.png` doppelt deklariert, `loading_1.png` fehlt als explizite Deklaration (wird durch `- assets/` abgedeckt, aber unordentlich). |

---

## Zusammenfassung

| Priorität | Anzahl |
|---|---|
| BLOCKER | 4 |
| HIGH | 5 |
| MEDIUM | 16 |
| NICE-TO-HAVE | 12 |
| **Gesamt** | **37** |

**Für den Beta-Release sind mindestens die 4 Blocker zu beheben:**
1. `.env` aus Assets entfernen → `--dart-define` nutzen
2. Eigenen Keystore erstellen und in `build.gradle.kts` einbinden
3. Tablet-Login-Bug fixen (Formular in Wide-Layout einfügen)
4. `debugShowCheckedModeBanner: true` auf `false` setzen

---

*Generiert von Claude Sonnet 4.6 via Claude Code · Nur Analyse, keine Code-Änderungen vorgenommen*

//user_SessionManager.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class UserSessionmanager {
  static final supabase = Supabase.instance.client;

  static Future<void> initialize() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _syncProfile(user).timeout(
        Duration(seconds: 8),
        onTimeout: () {
          dLog('[SessionManager] Timeout - nutze lokalen Cache');
        },
      );
    } on SocketException {
      dLog('[SessionManaher] Keine Internetverbindung');
    } catch (e) {
      dLog('[SessionManager] Fehler beim Profil-Sync: $e');
      dLog('[SessionManager] Fahre ohne Sync fort');
    }
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: user.id));
    });
  }

  static Future<void> _syncProfile(User user) async {
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return;

    await UserLocalServices.saveUserProfile(
      firstName: profile['first_name'] ?? '',
      lastName: profile['last_name'] ?? '',
      username: profile['username'] ?? '',
      birthdate: profile['birthdate'] ?? '',
    );
  }

  static Future<void> logout() async {
    await Workmanager().cancelAll();
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
    await supabase.auth.signOut();
    await UserLocalServices.clearUserProfile();
  }
}

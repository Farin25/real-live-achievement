//user_SessionManager.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'services.dart';

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
    } catch (e) {
      dLog('[SessionManager] Fehler beim Profil-Sync: $e');
      dLog('[SessionManager] Fahre ohne Sync fort');
    }
  }

  static Future<void> _syncProfile(User user) async {
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    await UserLocalServices.saveUserProfile(
      firstName: profile['first_name'] ?? '',
      lastName: profile['last_name'] ?? '',
      username: profile['username'] ?? '',
      birthdate: profile['birthdate'] ?? '',
    );
  }

  static Future<void> logout() async {
    await Workmanager().cancelAll();
    await supabase.auth.signOut();
    await UserLocalServices.clearUserProfile();
  }
}

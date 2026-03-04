import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_local_services.dart';


class UserSessionmanager {
 static final supabase = Supabase.instance.client;

  static Future<void> initialize() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await _syncProfile(user);
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
    await supabase.auth.signOut();
    await UserLocalServices.clearUserProfile();
  }


}
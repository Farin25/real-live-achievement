import 'package:shared_preferences/shared_preferences.dart';

class UserLocalServices {

  static Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String birthdate,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('first_name', firstName);
    await prefs.setString('last_name', lastName);
    await prefs.setString('username', username);
    await prefs.setString('birthdate', birthdate);
  }

}
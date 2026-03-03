import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

 
class UserDataServices {

   
  //----------------------------------
  //------------- Geburstag ----------
  ///---------------------------------
  static Future<int?> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();

    String? birthdateString = prefs.getString('birthdate');

     // Wenn lokal kein geburstdatum gespeichrt dann supbase fragen
    if (birthdateString == null) {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return null;

      final profile = await supabase
          .from('profiles')
          .select('birthday')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || profile['birthday'] == null) return null;
      
      birthdateString = profile['birthday'];
      

      await prefs.setString('birthdate', birthdateString!);
    }
     
     // Rechtent alter aus
    final birthday = DateTime.parse(birthdateString!);
    final now = DateTime.now();

    int age = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age;
  }
}

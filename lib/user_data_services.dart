import 'package:supabase_flutter/supabase_flutter.dart';


class UserDataServices {
static Future<int?> getUserAge() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final profile = await supabase
      .from('profiles')
      .select('birthday')
      .eq('id', user.id)
      .single();

  final birthday = DateTime.parse(profile['birthday']);
  final now = DateTime.now();

  int age = now.year - birthday.year;

  if (now.month < birthday.month ||
      (now.month == birthday.month && now.day < birthday.day)) {
    age--;
  }

  return age;
}

 }
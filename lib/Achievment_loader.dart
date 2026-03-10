import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementService {

  static final supabase = Supabase.instance.client;

  static Future<List<Map<String,dynamic>>> loadAchievements() async {

    final data = await supabase
        .from('achievements')
        .select();

    return List<Map<String,dynamic>>.from(data);

  }

}
import 'package:shared_preferences/shared_preferences.dart';




class AchievmentResult {
  final bool unlocked;
  final double progress;

  AchievmentResult({
    required this.unlocked,
    required this.progress,
  });
}

class AchievmentEngine {

  static AchievmentResult evaluate(
    Map<String, dynamic> achievment,
    Map<String, dynamic> userStatus,
  ) 
  {
    final requirement = achievment['requirement'];

    if (requirement == null) {
      print("Fehler keine informationen in der requiremen Spalte gefunden");

      return AchievmentResult(
        unlocked: false,
        progress: 0,
      );
     
      
      
    }
      // vorübergehendes Falback
    return AchievmentResult(
      unlocked: false,
     progress: 0,
     );


  }
}
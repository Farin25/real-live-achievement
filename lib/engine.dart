

// Berechnet Fortshcritt und wie weit freigeschaltet
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
  ) {

    final requirement = achievment['requirement'];

    if (requirement == null) {
      return AchievmentResult(unlocked: false, progress: 0);
    }

    final type = requirement['type'];
    final value = requirement['value'];

    if (type == null || value == null) {
      return AchievmentResult(unlocked: false, progress: 0);
    }

    final num requiredValue =
        value is num ? value : num.tryParse(value.toString()) ?? 0;

    final num userValue =
        userStatus[type] is num ? userStatus[type] : 0;

    if (requiredValue == 0) {
      return AchievmentResult(unlocked: false, progress: 0);
    }

    double progress = userValue / requiredValue;

    if (progress > 1) progress = 1;

    final unlocked = userValue >= requiredValue;

    return AchievmentResult(
      unlocked: unlocked,
      progress: progress,
    );
  }
}



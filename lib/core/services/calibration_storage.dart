import 'package:shared_preferences/shared_preferences.dart';

class CalibrationStorage {
  static Future<void> saveThresholds({
    required double squat,
    required double jump,
    required double step,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("squatThreshold", squat);
    await prefs.setDouble("jumpThreshold", jump);
    await prefs.setDouble("stepThreshold", step);
  }

  static Future<Map<String, double>> loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "squat": prefs.getDouble("squatThreshold") ?? 12.0,
      "jump": prefs.getDouble("jumpThreshold") ?? 20.0,
      "step": prefs.getDouble("stepThreshold") ?? 6.0,
    };
  }
}

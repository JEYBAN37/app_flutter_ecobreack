import 'package:shared_preferences/shared_preferences.dart';

class MotionCalibrationService {
  static final MotionCalibrationService _instance = MotionCalibrationService._internal();
  factory MotionCalibrationService() => _instance;
  MotionCalibrationService._internal();

  static const String _key = 'motion_calibrated';

  Future<bool> isCalibrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setCalibrated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

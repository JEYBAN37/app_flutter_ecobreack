import 'dart:async';
import 'dart:math' as math;
import 'package:ecoapp/core/services/calibration_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

class PauseDetectorService {
  StreamSubscription? _sub;
  int counter = 0;

  double squatThreshold = 12.0;
  double jumpThreshold = 20.0;
  double stepThreshold = 6.0;

  double lastY = 0;
  double lastZ = 0;

  Future<void> loadCalibration() async {
    final thresholds = await CalibrationStorage.loadThresholds();
    squatThreshold = thresholds["squat"]!;
    jumpThreshold = thresholds["jump"]!;
    stepThreshold = thresholds["step"]!;
  }

  void start(Function(int) onUpdate) {
    _sub = accelerometerEvents.listen((event) {
      final y = event.y;
      final z = event.z;

      final diffY = (y - lastY).abs();
      final diffZ = (z - lastZ).abs();

      if (diffY > squatThreshold) {
        counter++;
        onUpdate(counter);
      } else if (diffZ > jumpThreshold) {
        counter++;
        onUpdate(counter);
      } else if (diffY > stepThreshold || diffZ > stepThreshold) {
        counter++;
        onUpdate(counter);
      }

      lastY = y;
      lastZ = z;
    });
  }

  void stop() {
    _sub?.cancel();
  }
}
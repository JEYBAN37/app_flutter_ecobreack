import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class MotionDetectorService {
  static const double threshold = 1.5;
  static const int debounceMs = 300;
  
  bool isCalibrating = false;
  bool isDetecting = false;
  int movementCount = 0;
  final int requiredMovements = 15;
  final void Function(bool) onDetectionComplete;
  final void Function(int) onMovementUpdate;
  
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastMovementTime;

  MotionDetectorService({
    required this.onDetectionComplete,
    required this.onMovementUpdate,
  });

  void startDetecting() {
    isDetecting = true;
    movementCount = 0;
    
    _subscription?.cancel();
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (!isDetecting) return;

      final movement = _calculateMovement(event);
      final now = DateTime.now();
      
      if (movement > threshold && !isCalibrating &&
          (_lastMovementTime == null || 
           now.difference(_lastMovementTime!).inMilliseconds > debounceMs)) {
        
        isCalibrating = true;
        movementCount++;
        _lastMovementTime = now;
        onMovementUpdate(movementCount);

        Future.delayed(const Duration(milliseconds: debounceMs), () {
          isCalibrating = false;
        });

        if (movementCount >= requiredMovements) {
          isDetecting = false;
          onDetectionComplete(true);
          stopDetecting();
        }
      }
    });
  }

  double _calculateMovement(AccelerometerEvent event) {
    return (event.x.abs() + event.y.abs() + event.z.abs()) / 3;
  }

  void stopDetecting() {
    isDetecting = false;
    _subscription?.cancel();
    _subscription = null;
  }
}

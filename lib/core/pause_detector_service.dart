import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PauseDetectorService {
  static const double movementThreshold = 1.2; // Increased threshold
  static const double minMovement = 0.3; // Minimum movement to consider
  static const int consecutiveReadingsNeeded = 3; // Readings needed to confirm movement
  static const int requiredDuration = 10;
  static const int noMovementAlertSeconds = 3;

  bool isDetecting = false;
  bool movementSuccess = false;
  DateTime? startTime;
  Timer? movementTimer;
  final Function(bool) onPauseDetected;
  final Function(int) onProgressUpdate;
  final VoidCallback onTimeout;
  Timer? timeoutTimer;

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _secondsElapsed = 0;
  bool _moving = false;
  FlutterTts? _flutterTts;
  int _noMovementSeconds = 0;
  bool _alertedNoMovement = false;
  bool _alertedMovement = false;
  double? _lastX, _lastY, _lastZ;
  int _consecutiveMovements = 0;
  final List<double> _recentMovements = [];
  static const int recentMovementsToTrack = 5;

  PauseDetectorService({
    required this.onPauseDetected,
    required this.onProgressUpdate,
    required this.onTimeout,
  }) {
    _flutterTts = FlutterTts();
  }

  void startDetecting() {
    dev.log('[LOG] startDetecting() llamado');

    if (isDetecting) {
      dev.log('[LOG] Ya está detectando, no se inicia de nuevo');
      return;
    }

    if (kIsWeb) {
      dev.log('[ERROR] Los sensores no están disponibles en Flutter Web');
      onTimeout();
      return;
    }

    isDetecting = true;
    movementSuccess = false;
    startTime = DateTime.now();
    _secondsElapsed = 0;
    _moving = false;
    _noMovementSeconds = 0;
    _alertedNoMovement = false;
    _alertedMovement = false;
    _lastX = null;
    _lastY = null;
    _lastZ = null;

    dev.log('[PauseDetectorService] Iniciando detección de movimiento...');
    dev.log('[PauseDetectorService] Suscribiéndose al acelerómetro...');

    int eventCount = 0;
    Timer(const Duration(seconds: 3), () {
      if (eventCount == 0) {
        dev.log('[ERROR] No se han recibido eventos del sensor en 3 segundos. El sensor podría no estar funcionando.');
        stopDetecting();
        onTimeout();
      } else {
        dev.log('[LOG] Sensor funcionando correctamente. Eventos recibidos: $eventCount');
      }
    });

    timeoutTimer?.cancel();
    timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (isDetecting && _secondsElapsed < requiredDuration) {
        dev.log('[Timeout] No se alcanzó la duración requerida.');
        stopDetecting();
        onTimeout();
      }
    });

    _subscription?.cancel();
    _subscription = accelerometerEvents.listen(
      (AccelerometerEvent? event) {
        if (!isDetecting || event == null) return;

        eventCount++;
        final movement = _calculateDeltaMovement(event);
        
        if (movement > movementThreshold) {
          _consecutiveMovements++;
          if (_consecutiveMovements >= consecutiveReadingsNeeded) {
            _moving = true;
          }
        } else if (movement < minMovement) {
          _consecutiveMovements = 0;
          _moving = false;
        }

        dev.log('[Acelerómetro #$eventCount] Delta: $movement, Consecutivos: $_consecutiveMovements, Moviendo: $_moving');
      },
      onError: (e) {
        dev.log('[ERROR] Error en acelerómetro: $e');
        stopDetecting();
        onTimeout();
      },
      cancelOnError: true,
    );

    movementTimer?.cancel();
    movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!isDetecting) {
        timer.cancel();
        return;
      }

      if (_moving) {
        _secondsElapsed++;
        _noMovementSeconds = 0;
        dev.log('[Movimiento detectado] $_secondsElapsed segundos acumulados');
        onProgressUpdate(_secondsElapsed);
        _moving = false;

        if (!_alertedMovement) {
          await _speak('¡Movimiento detectado!');
          _alertedMovement = true;
          _alertedNoMovement = false;
        }

        if (_secondsElapsed >= requiredDuration) {
          movementSuccess = true;
          dev.log('[COMPLETADO] Requisito de movimiento alcanzado');
          _registerPauseActivity();
          onPauseDetected(true);
          stopDetecting();
        }
      } else {
        _noMovementSeconds++;
        dev.log('[Sin movimiento] Progreso: $_secondsElapsed');
        onProgressUpdate(_secondsElapsed);

        if (_noMovementSeconds >= noMovementAlertSeconds && !_alertedNoMovement) {
          await _speak('No se está reconociendo el movimiento. Mueve el celular en tu mano.');
          _alertedNoMovement = true;
          _alertedMovement = false;
        }
      }
    });
  }

  double _calculateDeltaMovement(AccelerometerEvent event) {
    double delta = 0.0;
    if (_lastX != null && _lastY != null && _lastZ != null) {
      // Calculate delta using root mean square for better accuracy
      final dx = event.x - _lastX!;
      final dy = event.y - _lastY!;
      final dz = event.z - _lastZ!;
      delta = math.sqrt((dx * dx + dy * dy + dz * dz) / 3.0);
      
      // Track recent movements for smoothing
      _recentMovements.add(delta);
      if (_recentMovements.length > recentMovementsToTrack) {
        _recentMovements.removeAt(0);
      }
    }
    
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;

    // Return smoothed movement value
    return _recentMovements.isNotEmpty 
        ? _recentMovements.reduce((a, b) => a + b) / _recentMovements.length 
        : delta;
  }

  Future<void> _speak(String text) async {
    if (_flutterTts != null) {
      await _flutterTts!.speak(text);
    }
  }

  Future<void> _registerPauseActivity() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('pausas').add({
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'pausa_activa',
          'duration': requiredDuration,
        });
        dev.log('[LOG] Pausa registrada en Firestore');
      }
    } catch (e) {
      debugPrint('[ERROR] Error al registrar pausa: $e');
    }
  }

  void stopDetecting() {
    dev.log('[LOG] Deteniendo detección de movimiento...');
    isDetecting = false;
    _subscription?.cancel();
    _subscription = null;
    timeoutTimer?.cancel();
    timeoutTimer = null;
    movementTimer?.cancel();
    movementTimer = null;
    _flutterTts?.stop();
    _consecutiveMovements = 0;
    _recentMovements.clear();
  }

  void dispose() {
    stopDetecting();
  }
}

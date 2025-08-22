import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecoapp/presentation/pages/menu/actividades/actividades_page.dart';
import 'pause_detector_service.dart';
import 'package:ecoapp/core/services/tts_service.dart';
import 'package:ecoapp/core/services/motion_calibration_service.dart';

class MotionDetectorDialog extends StatefulWidget {
  final String activityTitle;
  final String activityCategory;
  final List<String> instructions;

  const MotionDetectorDialog({
    super.key,
    required this.activityTitle,
    required this.activityCategory,
    required this.instructions,
  });

  @override
  State<MotionDetectorDialog> createState() => _MotionDetectorDialogState();
}

class _MotionDetectorDialogState extends State<MotionDetectorDialog> {
  late PauseDetectorService _detector;
  final _tts = TTSService();
  final _calibrationService = MotionCalibrationService();
  bool isDetectionComplete = false;
  bool isFirstAnimationComplete = false;
  bool isDetectionFailed = false;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _detector = PauseDetectorService(
      onPauseDetected: (success) {
        if (success && mounted) {
          setState(() {
            isDetectionComplete = true;
            isDetectionFailed = false;
          });
          _tts.speak('¡Sensor calibrado correctamente! Presiona el botón para comenzar tu pausa activa.');
          _calibrationService.setCalibrated();
        }
      },
      onProgressUpdate: (seconds) {
        if (mounted) {
          setState(() {
            secondsElapsed = seconds;
          });
          if (seconds == 0) {
            _tts.speak('No se está detectando movimiento. Por favor, mueve el dispositivo');
          }
        }
      },
      onTimeout: () {
        _tts.speak('No se detectó suficiente movimiento. Por favor, intenta nuevamente');
        if (mounted) {
          setState(() {
            isDetectionFailed = true;
          });
        }
      },
    );

    _initializeDetection();
  }

  void _initializeDetection() async {
    if (!mounted) return;

    setState(() {
      isFirstAnimationComplete = false;
      isDetectionComplete = false;
    });

    _tts.speak('Esta pausa activa requiere calibrar el sensor de movimiento. Por favor, mueve tu dispositivo suavemente.');

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isFirstAnimationComplete = true;
        });
        startDetection();
      }
    });
  }

  void startDetection() {
    setState(() {
      isDetectionComplete = false;
      isDetectionFailed = false;
      secondsElapsed = 0;
    });

    _detector.startDetecting();
  }

  void _onDetectionComplete(bool success) {
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ActividadesPage()), // Actualizado
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFirstAnimationComplete) ...[
              Lottie.asset(
                'assets/animaciones/movimiento.json',
                width: 200,
                height: 200,
              ),
              const Text(
                'Esta pausa activa requiere uso del detector de movimiento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Prepárate para mover tu dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else if (!isDetectionComplete && !isDetectionFailed) ...[
              Lottie.asset(
                'assets/animaciones/detectando.json',
                width: 200,
                height: 200,
              ),
              Text(
                'Calibrando sensor de movimiento\nMantén el movimiento por:\n$secondsElapsed/10 segundos',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mantén un movimiento constante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else if (isDetectionComplete) ...[
              Lottie.asset(
                'assets/animaciones/detectado_exito.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const Text(
                '¡Sensor calibrado con éxito!\nPuedes comenzar tu pausa activa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _onDetectionComplete(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'INICIAR PAUSA ACTIVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaRounded',
                    ),
                  ),
                ),
              ),
            ] else if (isDetectionFailed) ...[
              Lottie.asset(
                'assets/animaciones/fallo.json',
                width: 200,
                height: 200,
              ),
              const Text(
                '¡No se detectó suficiente movimiento!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  startDetection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0067AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'VOLVER A INTENTAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

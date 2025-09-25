import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecoapp/core/services/tts_service.dart';


class MotionDetectorDialog extends StatefulWidget {

  const MotionDetectorDialog({
    super.key,
  });

  @override
  State<MotionDetectorDialog> createState() => _MotionDetectorDialogState();
}

class _MotionDetectorDialogState extends State<MotionDetectorDialog> {
  Future<bool> _onWillPop() async {
    // Si el usuario intenta cerrar con atrás, regresa a la pantalla anterior
    if (mounted) Navigator.of(context).pop(false);
    return false;
  }

  final _tts = TTSService();
  bool isDetectionComplete = false;
  bool isFirstAnimationComplete = false;
  bool isDetectionFailed = false;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _initializeDetection();
  }

  void _initializeDetection() async {
    _tts.speak('Este ejercicio detectará tu movimiento.\nConcéntrate');

    Future.delayed(const Duration(seconds: 6), () {
      startDetection();
    });
  }

  void startDetection() {
    setState(() {
      isDetectionComplete = false;
      isDetectionFailed = false;
      secondsElapsed = 0;
    });

  }


  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white, // <-- Fondo blanco para el cuadro
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Lottie.asset(
              'assets/animaciones/detectando.json',
              width: 200,
              height: 200,
            ),
            const Text(
              'Este ejercicio\ndetectara tu movimiento\n¡Concentrate!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0067AC),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // <-- Cierra el diálogo y sigue el ejercicio
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Botón blanco (opcional)
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.play_arrow,
                    color: Color.fromARGB(255, 3, 3, 3)),
                label: const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaRounded',
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

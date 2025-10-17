
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MovementDetectorWidget extends StatelessWidget {
  final bool isDetecting;
  final int seconds;
  final bool success;
  final bool timeout;
  final Color color;

  const MovementDetectorWidget({
    super.key,
    required this.isDetecting,
    required this.seconds,
    required this.success,
    required this.timeout,
    required this.color,
  });


  @override
  Widget build(BuildContext context) {
    // Animación y texto según estado
    if (!isDetecting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animaciones/fallo.json',
              width: 48, height: 48, repeat: true),
          const SizedBox(width: 8),
          Text('No se detectó movimiento',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animaciones/detectado_exito.json',
            width: 48, height: 48, repeat: true),
        const SizedBox(width: 8),
        Text('Detectando  movimiento',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}


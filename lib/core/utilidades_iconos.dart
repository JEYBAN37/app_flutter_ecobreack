import 'package:flutter/material.dart';

class UtilidadesIconos {
  static IconData obtenerIcono(String iconName) {
    switch (iconName) {
      case 'Icons.visibility':
        return Icons.visibility;
      case 'Icons.remove_red_eye':
        return Icons.remove_red_eye;
      case 'Icons.hearing':
        return Icons.hearing;
      case 'Icons.headphones':
        return Icons.headphones;
      case 'Icons.psychology':
        return Icons.psychology;
      case 'Icons.numbers':
        return Icons.numbers;
      case 'Icons.rotate_right':
        return Icons.rotate_right;
      case 'Icons.directions_walk':
        return Icons.directions_walk;
      case 'Icons.pan_tool':
        return Icons.pan_tool;
      case 'Icons.self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.accessibility_new;
    }
  }

  static String formatearDuracion(dynamic duracion) {
    if (duracion is int) {
      final min = (duracion ~/ 60).toString().padLeft(2, '0');
      final sec = (duracion % 60).toString().padLeft(2, '0');
      return '$min:$sec';
    }
    return duracion.toString();
  }
}

import 'package:flutter/material.dart';

class RepsCounterWidget extends StatelessWidget {
  final int repeticiones;
  final Color color;
  const RepsCounterWidget(
      {super.key, required this.repeticiones, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          'Porcentaje: $repeticiones',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

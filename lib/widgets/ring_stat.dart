import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RingStat extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  final TextStyle valueStyle;
  final TextStyle labelStyle;
  final double radius; // Add radius parameter

  const RingStat({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.valueStyle,
    required this.labelStyle,
    this.radius = 60.0, // Default radius
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: radius, // Use the radius parameter
      lineWidth: 10.0,
      percent: percent.clamp(0.0, 1.0),
      animation: true,
      animationDuration: 1000,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: const Color(0xFF186188).withAlpha((0.2 * 255).toInt()),
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withAlpha((0.7 * 255).toInt()),
          color,
        ],
      ),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}
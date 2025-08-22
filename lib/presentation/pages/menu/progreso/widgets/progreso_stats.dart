import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgresoStats extends StatelessWidget {
  const ProgresoStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Progreso por Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                  fontFamily: 'HelveticaRounded',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6DA23).withAlpha(26), // Cambiado de withOpacity(0.1)
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            'Tren Superior',
            0.85,
            const Color(0xFF0067AC),
            '17/20',
            Icons.accessibility_new,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Tren Inferior',
            0.65,
            const Color(0xFFC6DA23),
            '13/20',
            Icons.directions_walk,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Movilidad Articular',
            0.45,
            Colors.orange,
            '9/20',
            Icons.self_improvement,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Estiramientos Generales',
            0.30,
            Colors.purple,
            '6/20',
            Icons.accessibility,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double progress,
    Color color,
    String fraction,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(26), // Cambiado de withOpacity(0.1)
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                fraction,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 8,
          percent: progress,
          backgroundColor: Colors.grey[200],
          progressColor: color,
          padding: EdgeInsets.zero,
          barRadius: const Radius.circular(4),
          animation: true,
          animationDuration: 1000,
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
}

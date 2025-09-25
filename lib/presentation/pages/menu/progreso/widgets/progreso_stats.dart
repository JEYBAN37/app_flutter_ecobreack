import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgresoStats extends StatelessWidget {
  final Map<String, int> groupedByCategory;
  final bool esMensual;
  const ProgresoStats(
      {super.key, required this.groupedByCategory, this.esMensual = false});

  static const Map<String, IconData> _categoryIcons = {
    'Visual': Icons.visibility,
    'Auditiva': Icons.hearing,
    'Cognitiva': Icons.psychology,
    'Accesibilidad': Icons.accessibility_new,
    'Tren Superior': Icons.accessibility_new,
    'Tren Inferior': Icons.directions_walk,
    'Movilidad Articular': Icons.self_improvement,
    'Estiramientos Generales': Icons.extension,
    'Movilidad': Icons.self_improvement,
  };

  static Color getCardColor(String category) {
    switch (category) {
      case 'Visual':
        return const Color(0xFF4FC3F7); // Azul claro
      case 'Auditiva':
        return const Color(0xFF9575CD); // Morado
      case 'Cognitiva':
        return const Color(0xFFFFB74D); // Naranja
      case 'Accesibilidad':
      case 'Tren Superior':
        return const Color(0xFF1976D2); // Azul fuerte
      case 'Tren Inferior':
        return const Color(0xFFC6DA23); // Verde claro
      case 'Movilidad Articular':
      case 'Movilidad':
        return const Color(0xFF26C6DA); // Turquesa
      case 'Estiramientos Generales':
        return const Color(0xFFFF8A65); // Naranja suave
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista de categorías a mostrar (puedes ajustar el orden aquí)
    final categorias = [
      'Accesibilidad',
      'Tren Superior',
      'Tren Inferior',
      'Movilidad Articular',
      'Estiramientos Generales',
      'Visual',
      'Auditiva',
      'Cognitiva',
      'Movilidad',
    ];

    final divisor = esMensual ? 20 : 5;

    // Calcular suma total según reglas
    int sumaActividades = 0;
    groupedByCategory.forEach((cat, value) {
      if (esMensual) {
        sumaActividades += value;
      } else {
        sumaActividades += value > 5 ? 5 : value;
      }
    });

    final int totalMax = esMensual ? 180 : 45;
    final double porcentajeTotal = (esMensual
            ? sumaActividades / totalMax
            : (sumaActividades > 45 ? 45 : sumaActividades) / 45)
        .clamp(0.0, 1.0);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6DA23).withAlpha(26),
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
                      '${(porcentajeTotal * 100).toStringAsFixed(0)}%',
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
          ...categorias.map((cat) {
            final value = groupedByCategory[cat] ?? 0;
            final percent = (value / divisor).clamp(0.0, 1.0);
            final icon = _categoryIcons[cat] ?? Icons.category;
            final color = getCardColor(cat);
            // En semanal muestra máximo 5, en mensual muestra el valor real
            final fraccion = esMensual
                ? '$value/$divisor'
                : '${value > 5 ? 5 : value}/$divisor';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProgressBar(
                cat,
                percent,
                color,
                fraccion,
                icon,
              ),
            );
          }).toList(),
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
                color: color.withAlpha(26),
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

  static double _getTotalPercent(Map<String, int> grouped,
      {bool esMensual = false}) {
    if (grouped.isEmpty) return 0;
    final divisor = esMensual ? 20 : 5;
    final total = grouped.values.fold(0, (a, b) => a + b);
    final percent = total / (grouped.length * divisor);
    return (percent * 100).clamp(0, 100);
  }
}

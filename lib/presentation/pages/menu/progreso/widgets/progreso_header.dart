import 'package:flutter/material.dart';

class ProgresoHeader extends StatelessWidget {
  final int completadas;
  final bool esMensual; // true = mes (180), false = semana (45)
  const ProgresoHeader({
    super.key,
    required this.completadas,
    this.esMensual = false,
  });

  @override
  Widget build(BuildContext context) {
    final int total = esMensual ? 12 * 4 : 21;
    final int pendientes = (total - completadas).clamp(0, total);
    final double cumplimiento =
        total > 0 ? ((completadas / total) * 100).clamp(0, 100) : 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 1,
              child: _buildStatCard('${cumplimiento.toStringAsFixed(0)}%',
                  'Cumplimiento', Colors.blue),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 1,
              child:
                  _buildStatCard('$completadas', 'Completadas', Colors.green),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 1,
              child: _buildStatCard('$pendientes', 'Pendientes', Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgresoChart extends StatelessWidget {
  final Map<String, int> groupedByDay;
  final String modo; // 'semana' o 'mes'
  const ProgresoChart(
      {super.key, required this.groupedByDay, required this.modo});

  @override
  Widget build(BuildContext context) {
    List<String> sortedKeys;
    List<double> values;

    if (modo == 'semana') {
      // ...existing code...
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      sortedKeys = List.generate(7, (i) {
        final d = startOfWeek.add(Duration(days: i));
        return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      });
      values =
          sortedKeys.map((k) => groupedByDay[k]?.toDouble() ?? 0.0).toList();
    } else if (modo == 'mes') {
      // Para vista mensual, generar todos los días del mes
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      sortedKeys = List.generate(daysInMonth, (i) {
        final d = DateTime(now.year, now.month, i + 1);
        return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      });
      values =
          sortedKeys.map((k) => groupedByDay[k]?.toDouble() ?? 0.0).toList();
    } else {
      // ...existing code...
      sortedKeys = groupedByDay.keys.toList()..sort();
      values = sortedKeys.map((k) => groupedByDay[k]!.toDouble()).toList();
    }

    // Si es mes y hay muchos días, usa gráfico de líneas
    if (modo == 'mes' && sortedKeys.length > 14) {
      final maxY =
          ((values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 10) +
                  2)
              .toDouble();
      final interval =
          (values.isNotEmpty && values.reduce((a, b) => a > b ? a : b) > 5)
              ? (values.reduce((a, b) => a > b ? a : b) / 5).ceilToDouble()
              : 1.0;
      return LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (sortedKeys.length / 6).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= sortedKeys.length)
                    return const SizedBox.shrink();
                  final date = DateTime.parse(sortedKeys[idx]);
                  return Text('${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10));
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value % interval != 0) return const SizedBox.shrink();
                  return Text('${value.toInt()}',
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: interval,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      );
    }

    // Si es semana o pocos días, usa barras
    // Convertir siempre las fechas a nombres de días
    final weekDays = sortedKeys.map((k) {
      final date = DateTime.parse(k);
      return _getShortDayName(date.weekday);
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 10) +
                2,
        minY: 0,
        groupsSpace: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx < 0 || idx >= weekDays.length)
                  return const SizedBox.shrink();
                return Text(
                  weekDays[idx],
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (values.isNotEmpty &&
                      values.reduce((a, b) => a > b ? a : b) > 5)
                  ? (values.reduce((a, b) => a > b ? a : b) / 5).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                // Solo mostrar múltiplos del intervalo
                final interval = (values.isNotEmpty &&
                        values.reduce((a, b) => a > b ? a : b) > 5)
                    ? (values.reduce((a, b) => a > b ? a : b) / 5)
                        .ceilToDouble()
                    : 1;
                if (value % interval != 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: values[index] == 0.0
                    ? Colors.grey[300]
                    : _getBarColor(values[index]),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getBarColor(double value) {
    if (value < 5) return Colors.red;
    if (value < 10) return const Color(0xFFC6DA23); // Amarillo/verde claro
    return Colors.green;
  }

  static String _getShortDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mié';
      case DateTime.thursday:
        return 'Jue';
      case DateTime.friday:
        return 'Vie';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }
}

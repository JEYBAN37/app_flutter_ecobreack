import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgresoChart extends StatelessWidget {
  final List<double> weeklyData = [65, 20, 50, 90, 75, 60, 85];
  final List<String> weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  ProgresoChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        groupsSpace: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  weekDays[value.toInt()],
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
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
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
          horizontalInterval: 20,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          weeklyData.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyData[index],
                color: _getBarColor(weeklyData[index]),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarColor(double value) {
    if (value < 40) return Colors.red;
    if (value < 70) return const Color(0xFFC6DA23);
    return Colors.green;
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChart extends StatelessWidget {
  final Map<String, int> data;

  const CustomBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();
    final theme = Theme.of(context).colorScheme;

    List<BarChartGroupData> barGroups = data.entries
        .toList()
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          int value = entry.value.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                color: theme.primary,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        })
        .toList();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < keys.length) {
                    // Acortamos el texto si es muy largo para que quepa abajo
                    String text = keys[value.toInt()];
                    if (text.length > 7) text = '${text.substring(0, 7)}.';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            // Ocultamos los títulos de arriba y la derecha para un diseño más limpio
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

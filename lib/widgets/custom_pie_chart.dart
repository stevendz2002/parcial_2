import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomPieChart extends StatelessWidget {
  final Map<String, int> data;

  const CustomPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    final entries = data.entries.toList();

    List<PieChartSectionData> sections = List.generate(entries.length, (index) {
      final entry = entries[index];
      final color = AppTheme.chartColors[index % AppTheme.chartColors.length];
      final percentage = total > 0
          ? ((entry.value / total) * 100).toStringAsFixed(1)
          : "0";

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

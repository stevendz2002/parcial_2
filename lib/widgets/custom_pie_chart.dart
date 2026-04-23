import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatelessWidget {
  final Map<String, int> data;

  const CustomPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Lista de colores para diferenciar las porciones de la torta
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    int colorIndex = 0;

    List<PieChartSectionData> sections = data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        // Mostramos el nombre y el valor en la torta
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomBarChart extends StatelessWidget {
  final Map<String, int> data;

  const CustomBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();
    final values = data.values.toList();

    List<BarChartGroupData> barGroups = List.generate(keys.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index].toDouble(),
            // Usamos los colores de tu AppTheme
            color: AppTheme.chartColors[index % AppTheme.chartColors.length],
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return SizedBox(
      height: 300, // Un alto fijo suficiente
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: values.isNotEmpty
                ? (values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2)
                : 100,
            barGroups: barGroups,
            // --- CORRECCIÓN DE TÍTULOS ---
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < keys.length) {
                      // Rotamos el texto un poco para que no choquen
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 10,
                        child: Transform.rotate(
                          angle: -0.5, // Rotación ligera (diagonal)
                          child: Text(
                            keys[index],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            // --- CORRECCIÓN DE TOOLTIP ---
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // En versiones recientes es tooltipBgColor, no getTooltipColor
                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${keys[groupIndex]}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: rod.toY.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

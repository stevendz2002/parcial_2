import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Rutas de ejemplo, ajusta según tu proyecto
import '../services/accidentes_service.dart';
import '../widgets/custom_pie_chart.dart';
import '../widgets/custom_bar_chart.dart';
import '../themes/app_theme.dart';

class AccidentesStatsView extends StatefulWidget {
  const AccidentesStatsView({super.key});

  @override
  State<AccidentesStatsView> createState() => _AccidentesStatsViewState();
}

class _AccidentesStatsViewState extends State<AccidentesStatsView> {
  late Future<Map<String, dynamic>> _estadisticasFuture;

  @override
  void initState() {
    super.initState();
    // Disparamos la petición pesada con el Isolate
    _estadisticasFuture = AccidentesService().getEstadisticas();
  }

  // Widget para contener cada gráfica en una tarjeta bonita
  Widget _buildChartCard(
    String title,
    Widget chart, {
    String? description,
    Map<String, int>? dataForLegend,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            chart,
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            if (dataForLegend != null && dataForLegend.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildLegendItems(dataForLegend),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Construye los ítems de la leyenda basado en los colores del AppTheme
  List<Widget> _buildLegendItems(Map<String, int> data) {
    final List<Widget> items = [];
    final keys = data.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      // Usamos el color centralizado
      final color = AppTheme.chartColors[i % AppTheme.chartColors.length];

      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(keys[i], style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Accidentes')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _estadisticasFuture,
        builder: (context, snapshot) {
          // ESTADO 1: ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // ESTADO 2: CARGANDO (Variables Mock para el Skeletonizer)
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          Map<String, dynamic> data = {
            'clase': {'Choque': 50, 'Atropello': 30},
            'gravedad': {'Heridos': 60, 'Daños': 40},
            'topBarrios': {'Centro': 100, 'Norte': 80, 'Sur': 60},
            'dias': {'Lunes': 10, 'Martes': 20, 'Viernes': 40},
          };

          // ESTADO 3: ÉXITO
          if (snapshot.hasData) {
            data = snapshot.data!;
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Distribución por clase de accidente -> PieChart
                _buildChartCard(
                  'Clase de Accidente',
                  CustomPieChart(data: data['clase']),
                  description:
                      'Distribución porcentual de los tipos de accidente registrados',
                  dataForLegend: data['clase'] as Map<String, int>?,
                ),

                // 2. Distribución por gravedad -> PieChart
                _buildChartCard(
                  'Gravedad del Accidente',
                  CustomPieChart(data: data['gravedad']),
                  description:
                      'Distribución porcentual según la gravedad de los accidentes',
                  dataForLegend: data['gravedad'] as Map<String, int>?,
                ),

                // 3. Top 5 barrios con más accidentes -> BarChart
                _buildChartCard(
                  'Top Barrios',
                  CustomBarChart(data: data['topBarrios']),
                  description: 'Barrios con mayor incidencia de accidentes',
                  dataForLegend: data['topBarrios'] as Map<String, int>?,
                ),

                // 4. Distribución por día de la semana -> BarChart
                _buildChartCard(
                  'Distribución por Día',
                  CustomBarChart(data: data['dias']),
                  description:
                      'Distribución de accidentes por día de la semana',
                  dataForLegend: data['dias'] as Map<String, int>?,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

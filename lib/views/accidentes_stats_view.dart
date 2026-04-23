import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/accidentes_service.dart';
import '../widgets/custom_pie_chart.dart';
import '../widgets/custom_bar_chart.dart';

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
  Widget _buildChartCard(String title, Widget chart) {
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
          ],
        ),
      ),
    );
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
                ),

                // 2. Distribución por gravedad -> PieChart (o BarChart, elegí Pie para variar)
                _buildChartCard(
                  'Gravedad del Accidente',
                  CustomPieChart(data: data['gravedad']),
                ),

                // 3. Top 5 barrios con más accidentes -> BarChart
                _buildChartCard(
                  'Top 5 Barrios',
                  CustomBarChart(data: data['topBarrios']),
                ),

                // 4. Distribución por día de la semana -> BarChart
                _buildChartCard(
                  'Distribución por Día',
                  CustomBarChart(data: data['dias']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

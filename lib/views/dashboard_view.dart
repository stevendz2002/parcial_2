import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/accidentes_service.dart';
import '../services/establecimientos_service.dart';
import '../widgets/dashboard_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Variable para guardar nuestra petición asíncrona
  late Future<Map<String, int>> _totalesFuture;

  @override
  void initState() {
    super.initState();
    _totalesFuture = _cargarTotales();
  }

  // Método que consulta ambas APIs al mismo tiempo
  Future<Map<String, int>> _cargarTotales() async {
    try {
      final resultados = await Future.wait([
        AccidentesService().getEstadisticas(),
        EstablecimientosService().getEstablecimientos(),
      ]);

      final statsAccidentes = resultados[0] as Map<String, dynamic>;
      final listaEstablecimientos = resultados[1] as List<dynamic>;

      return {
        'accidentes': statsAccidentes['total'] as int,
        'establecimientos': listaEstablecimientos.length,
      };
    } catch (e) {
      throw Exception('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      body: FutureBuilder<Map<String, int>>(
        future: _totalesFuture,
        builder: (context, snapshot) {
          // Si hay error, mostramos un mensaje amigable y un botón para reintentar
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Ocurrió un error:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _totalesFuture = _cargarTotales()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Variables de estado
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // Datos "falsos" (mock) que el Skeletonizer usará para dibujar los huesos
          int totalAccidentes = 100000;
          int totalEstablecimientos = 50;

          // Si ya cargó, reemplazamos los datos falsos por los reales
          if (snapshot.hasData) {
            totalAccidentes = snapshot.data!['accidentes']!;
            totalEstablecimientos = snapshot.data!['establecimientos']!;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            // 🔥 AQUÍ ESTÁ LA MAGIA DEL SKELETONIZER 🔥
            child: Skeletonizer(
              enabled: isLoading,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Accidentes de Tránsito',
                    subtitle: 'Total: $totalAccidentes',
                    icon: Icons.car_crash,
                    color: Colors.orange,
                    onTap: () {
                      if (!isLoading) context.push('/accidentes');
                    },
                  ),
                  DashboardCard(
                    title: 'Establecimientos',
                    subtitle: 'Registrados: $totalEstablecimientos',
                    icon: Icons.store,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      if (!isLoading) context.push('/establecimientos');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

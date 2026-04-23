import 'package:go_router/go_router.dart';
import '../views/dashboard_view.dart';
import '../views/accidentes_stats_view.dart';
import '../views/establecimientos_list_view.dart';
import '../views/establecimiento_form_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardView()),
    GoRoute(
      path: '/accidentes',
      builder: (context, state) => const AccidentesStatsView(),
    ),
    GoRoute(
      path: '/establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    GoRoute(
      path: '/establecimientos/form', // Ruta para CREAR (sin ID)
      builder: (context, state) => const EstablecimientoFormView(),
    ),
    GoRoute(
      path: '/establecimientos/form/:id', // Ruta para EDITAR/DETALLE (con ID)
      builder: (context, state) {
        // Extraemos el ID de la URL
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return EstablecimientoFormView(establecimientoId: id);
      },
    ),
  ],
);

import 'package:go_router/go_router.dart';
import '../views/dashboard_view.dart';
import '../views/accidentes_stats_view.dart';
import '../views/establecimientos_list_view.dart';
import '../views/establecimiento_form_view.dart';
import '../views/establecimiento_detail_view.dart';

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
      path: '/establecimientos/form',
      builder: (context, state) => const EstablecimientoFormView(),
    ),
    GoRoute(
      path: '/establecimientos/form/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return EstablecimientoFormView(establecimientoId: id);
      },
    ),
    GoRoute(
      path: '/establecimientos/detail/:id', // Actualizado a detail
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return EstablecimientoDetailView(id: id!);
      },
    ),
  ],
);

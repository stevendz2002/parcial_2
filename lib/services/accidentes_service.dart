import 'dart:isolate';
import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../models/accidente_model.dart';

class AccidentesService {
  final Dio _dio = Dio();

  // Método principal que llama la vista
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      // 1. Descargamos los 100,000 registros
      final response = await _dio.get(
        '${EnvConfig.apiAccidentes}?\$limit=100000',
      );
      final List<dynamic> data = response.data;

      // 2. Mandamos la data pesada a procesar a un Isolate (hilo secundario)
      // Esto evita que la app (el Skeletonizer) se congele mientras calcula.
      final stats = await Isolate.run(() => _procesarEstadisticas(data));

      return stats;
    } catch (e) {
      throw Exception('Error al cargar accidentes: $e');
    }
  }

  // --- LÓGICA DEL ISOLATE ---
  // IMPORTANTE: Debe ser un método estático para que el Isolate lo pueda ejecutar aislado.
  static Map<String, dynamic> _procesarEstadisticas(List<dynamic> data) {
    // Convertimos el JSON a Modelos
    final accidentes = data.map((e) => AccidenteModel.fromJson(e)).toList();

    // Contadores para las gráficas
    final claseCount = <String, int>{};
    final gravedadCount = <String, int>{};
    final barrioCount = <String, int>{};
    final diaCount = <String, int>{};

    for (var acc in accidentes) {
      // Distribución por clase (Choque, Volcamiento...)
      claseCount[acc.claseAccidente] =
          (claseCount[acc.claseAccidente] ?? 0) + 1;

      // Distribución por gravedad (Muertos, Heridos...)
      gravedadCount[acc.gravedadAccidente] =
          (gravedadCount[acc.gravedadAccidente] ?? 0) + 1;

      // Conteo de barrios (Omitimos si está vacío o es desconocido)
      if (acc.barrioHecho != 'DESCONOCIDO' && acc.barrioHecho.isNotEmpty) {
        barrioCount[acc.barrioHecho] = (barrioCount[acc.barrioHecho] ?? 0) + 1;
      }

      // Distribución por día
      diaCount[acc.dia] = (diaCount[acc.dia] ?? 0) + 1;
    }

    // Calcular el TOP 5 de Barrios
    var sortedBarrios = barrioCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Ordena de mayor a menor
    var top5Barrios = Map.fromEntries(sortedBarrios.take(5));

    // Retornamos el diccionario listo para que fl_chart lo pinte
    return {
      'total': accidentes.length,
      'clase': claseCount,
      'gravedad': gravedadCount,
      'topBarrios': top5Barrios,
      'dias': diaCount,
    };
  }
}

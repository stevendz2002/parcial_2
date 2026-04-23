import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../models/establecimiento_model.dart';

class EstablecimientosService {
  final Dio _dio = Dio();
  final String baseUrl = EnvConfig.apiParqueadero;

  // 1. GET ALL
  Future<List<EstablecimientoModel>> getEstablecimientos() async {
    try {
      final response = await _dio.get('$baseUrl/establecimientos');
      // Asegúrate de revisar cómo responde la API (si es un array directo o viene dentro de un "data")
      final List<dynamic> data = response.data;
      return data.map((e) => EstablecimientoModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener establecimientos: $e');
    }
  }

  // 2. GET ONE
  Future<EstablecimientoModel> getEstablecimiento(int id) async {
    try {
      final response = await _dio.get('$baseUrl/establecimientos/$id');
      return EstablecimientoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar detalle: $e');
    }
  }

  // 3. POST (CREAR CON IMAGEN)
  Future<void> createEstablecimiento(
    EstablecimientoModel est,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'nombre': est.nombre,
        'nit': est.nit,
        'direccion': est.direccion,
        'telefono': est.telefono,
        // Si el usuario seleccionó una foto con image_picker, la adjuntamos
        if (imagePath != null) 'logo': await MultipartFile.fromFile(imagePath),
      });

      await _dio.post('$baseUrl/establecimientos', data: formData);
    } catch (e) {
      throw Exception('Error al crear establecimiento: $e');
    }
  }

  // 4. PUT SPOOFING (EDITAR CON IMAGEN)
  Future<void> updateEstablecimiento(
    int id,
    EstablecimientoModel est,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        '_method':
            'PUT', // Truco de Laravel para aceptar multipart en actualización
        'nombre': est.nombre,
        'nit': est.nit,
        'direccion': est.direccion,
        'telefono': est.telefono,
        if (imagePath != null) 'logo': await MultipartFile.fromFile(imagePath),
      });

      // NOTA: Aunque es update, enviamos un POST a la ruta que nos diste
      await _dio.post('$baseUrl/establecimiento-update/$id', data: formData);
    } catch (e) {
      throw Exception('Error al actualizar: $e');
    }
  }

  // 5. DELETE
  Future<void> deleteEstablecimiento(int id) async {
    try {
      await _dio.delete('$baseUrl/establecimientos/$id');
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }
}

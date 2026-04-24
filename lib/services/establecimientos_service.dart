import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../models/establecimiento_model.dart';

class EstablecimientosService {
  late final Dio _dio;
  final String baseUrl = EnvConfig.apiParqueadero;
  final String logoBaseUrl = EnvConfig.apiLogoUrl;

  EstablecimientosService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  // Helper para procesar URL de logo
  void _processLogoUrl(Map<String, dynamic> json) {
    final logo = json['logo'];
    if (logo != null && logo.toString().isNotEmpty) {
      final logoStr = logo.toString();
      if (logoStr != 'sin-imagen.png' && !logoStr.startsWith('http')) {
        json['logo'] = '$logoBaseUrl/$logoStr';
      } else if (logoStr == 'sin-imagen.png') {
        json['logo'] = null;
      }
    }
  }

  // 1. GET ALL
  Future<List<EstablecimientoModel>> getEstablecimientos() async {
    try {
      final response = await _dio.get('/establecimientos');

      List<dynamic>? data;
      final respData = response.data;

      if (respData is List) {
        data = respData;
      } else if (respData is Map<String, dynamic>) {
        final map = respData;
        if (map['data'] is List) {
          data = map['data'] as List<dynamic>;
        } else if (map['establecimientos'] is List) {
          data = map['establecimientos'] as List<dynamic>;
        } else {
          for (var value in map.values) {
            if (value is List) {
              data = value;
              break;
            }
          }
        }
      } else {
        throw Exception(
          'Formato de respuesta inesperado: ${respData.runtimeType}',
        );
      }

      if (data == null) {
        throw Exception(
          'La respuesta de la API no contiene una lista de establecimientos',
        );
      }

      return data.map((e) {
        final json = Map<String, dynamic>.from(e);
        _processLogoUrl(json);
        return EstablecimientoModel.fromJson(json);
      }).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.statusMessage ??
          e.message;
      throw Exception(
        'Error al obtener establecimientos: $msg (${e.response?.statusCode})',
      );
    } catch (e) {
      throw Exception('Error al obtener establecimientos: $e');
    }
  }

  // 2. GET ONE
  Future<EstablecimientoModel> getEstablecimiento(int id) async {
    try {
      final response = await _dio.get('/establecimientos/$id');
      final respData = response.data;

      Map<String, dynamic> json;

      if (respData is Map<String, dynamic>) {
        if (respData['data'] is Map<String, dynamic>) {
          json = Map<String, dynamic>.from(respData['data']);
        } else if (respData['establecimiento'] is Map<String, dynamic>) {
          json = Map<String, dynamic>.from(respData['establecimiento']);
        } else {
          json = Map<String, dynamic>.from(respData);
        }
      } else {
        throw Exception(
          'Formato de respuesta inesperado al obtener detalle: ${respData.runtimeType}',
        );
      }

      _processLogoUrl(json);
      return EstablecimientoModel.fromJson(json);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.statusMessage ??
          e.message;
      throw Exception(
        'Error al cargar detalle: $msg (${e.response?.statusCode})',
      );
    } catch (e) {
      throw Exception('Error al cargar detalle: $e');
    }
  }

  // 3. POST (CREAR CON IMAGEN)
  Future<EstablecimientoModel> createEstablecimiento(
    EstablecimientoModel est,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'nombre': est.nombre,
        'nit': est.nit,
        'direccion': est.direccion,
        'telefono': est.telefono,
        if (imagePath != null)
          'logo': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
      });

      final response = await _dio.post(
        '/establecimientos',
        data: formData,
        options: Options(followRedirects: false),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = Map<String, dynamic>.from(response.data);
        if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
          final dataJson = Map<String, dynamic>.from(json['data']);
          _processLogoUrl(dataJson);
          return EstablecimientoModel.fromJson(dataJson);
        } else {
          _processLogoUrl(json);
          return EstablecimientoModel.fromJson(json);
        }
      } else {
        final errorMsg = response.data?['message'] ?? 'Respuesta inesperada';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.statusMessage ??
          e.message;
      throw Exception(
        'Error al crear establecimiento: $msg (${e.response?.statusCode})',
      );
    } catch (e) {
      throw Exception('Error al crear establecimiento: $e');
    }
  }

  // 4. UPDATE (EDITAR CON IMAGEN) - POST directo sin method spoofing
  Future<void> updateEstablecimiento(
    int id,
    EstablecimientoModel est, {
    Map<String, dynamic>? partialFields,
    String? imagePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap =
          partialFields ??
          {
            'nombre': est.nombre,
            'nit': est.nit,
            'direccion': est.direccion,
            'telefono': est.telefono,
          };

      if (imagePath != null) {
        dataMap['logo'] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(dataMap);

      await _dio.post('/establecimiento-update/$id', data: formData);
    } catch (e) {
      throw Exception('Error al actualizar el establecimiento: $e');
    }
  }

  // 5. DELETE
  Future<void> deleteEstablecimiento(int id) async {
    try {
      await _dio.delete('/establecimientos/$id');
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.statusMessage ??
          e.message;
      throw Exception('Error al eliminar: $msg (${e.response?.statusCode})');
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }
}

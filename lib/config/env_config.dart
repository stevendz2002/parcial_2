import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiAccidentes =>
      dotenv.env['API_ACCIDENTES_URL'] ??
      'https://www.datos.gov.co/resource/ezt8-5wyj.json';
  static String get apiParqueadero =>
      dotenv.env['API_PARQUEADERO_URL'] ??
      'https://parking.visiontic.com.co/api';
}

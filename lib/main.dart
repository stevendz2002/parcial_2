import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_router.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos el archivo .env antes de arrancar
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parcial Flutter Final',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Conectamos tu paleta de colores
      routerConfig: appRouter, // Conectamos tus rutas
    );
  }
}

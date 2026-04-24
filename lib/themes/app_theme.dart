import 'package:flutter/material.dart';

class AppTheme {
  // Colores específicos para gráficas
  static const List<Color> chartColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF388E3C), // Green
    Color(0xFFFBC02D), // Yellow/Amber
    Color(0xFF7B1FA2), // Purple
    Color(0xFF0097A7), // Teal
    Color(0xFFE64A19), // Deep Orange
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1976D2),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
    ),
  );
}

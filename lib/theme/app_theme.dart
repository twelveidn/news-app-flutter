import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color ink = Color(0xFF172033);
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color accent = Color(0xFFDF5B3F);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: ink, surface: canvas);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(primary: ink, secondary: accent),
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF586174),
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}

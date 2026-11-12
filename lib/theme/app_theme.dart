import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color ink = Color(0xFF10253F);
  static const Color canvas = Color(0xFFF4F7FB);
  static const Color accent = Color(0xFF3977B7);
  static const Color divider = Color(0xFFD8E1EC);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      surface: canvas,
    );

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: divider),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Georgia',
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF53647A),
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}

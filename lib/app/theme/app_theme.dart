import 'package:flutter/material.dart';

class AppTheme {
  static const Color _lightPrimary = Color(0xFF006D9B);
  static const Color _lightSecondary = Color(0xFF008B70);
  static const Color _lightSurface = Color(0xFFF4F7FB);

  static const Color _darkPrimary = Color(0xFF69D8FF);
  static const Color _darkSecondary = Color(0xFF64F0C7);
  static const Color _darkSurface = Color(0xFF0B1320);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightSurface,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.22),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkSurface,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF111D2F),
        indicatorColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _darkPrimary,
        inactiveTrackColor: _darkPrimary.withValues(alpha: 0.2),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF142237),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Color and theme utilities
library color_utils;

import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFECB3);
  static const Color secondaryDark = Color(0xFFF57C00);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Divider and border
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);

  // BMI Category colors
  static const Color bmiUnderweight = Color(0xFF2196F3);
  static const Color bmiNormal = Color(0xFF4CAF50);
  static const Color bmiOverweight = Color(0xFFFF9800);
  static const Color bmiObese = Color(0xFFF44336);
}

/// Color extensions
extension ColorExtension on Color {
  /// Get material color
  MaterialColor toMaterialColor() {
    return MaterialColor(value, <int, Color>{
      50: withOpacity(0.1),
      100: withOpacity(0.2),
      200: withOpacity(0.3),
      300: withOpacity(0.4),
      400: withOpacity(0.5),
      500: withOpacity(0.6),
      600: withOpacity(0.7),
      700: withOpacity(0.8),
      800: withOpacity(0.9),
      900: this,
    });
  }

  /// Get contrast color (black or white)
  Color getContrastColor() {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }
}

/// Theme mode utilities
class ThemeUtils {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// BMI category to color mapping
class BMICategoryColors {
  static Color getColorForBMI(double bmi) {
    if (bmi < 18.5) return AppColors.bmiUnderweight;
    if (bmi < 25) return AppColors.bmiNormal;
    if (bmi < 30) return AppColors.bmiOverweight;
    return AppColors.bmiObese;
  }

  static String getCategoryName(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static Color getBackgroundColor(double bmi) {
    return getColorForBMI(bmi).withOpacity(0.1);
  }
}

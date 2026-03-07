import 'package:flutter/material.dart';

class KuliColors {
  static const Color background = Color(0xFF0F0F1E);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color primary = Color(0xFF9D59FF);
  static const Color secondary = Color(0xFF7000FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color accentGlow = Color(0xFF9D59FF);
  static const Color glassBorder = Color(0xFF2E2E3E);
}

class KuliTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KuliColors.background,
      primaryColor: KuliColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: KuliColors.primary,
        secondary: KuliColors.secondary,
        surface: KuliColors.surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: KuliColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: KuliColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        bodyLarge: TextStyle(color: KuliColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: KuliColors.textSecondary, fontSize: 14),
      ),
      useMaterial3: true,
    );
  }
}

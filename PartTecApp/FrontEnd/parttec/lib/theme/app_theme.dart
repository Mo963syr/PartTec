import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF3949AB);
  static const bgGradientA = Color(0xFF1976D2);
  static const bgGradientB = Color(0xFF42A5F5);
  static const bgGradientC = Color(0xFF5C6BC0);

  static const card = Colors.white;
  static const text = Colors.black87;
  static const textWeak = Colors.black54;
  static const chipBg = Colors.white;
  static const chipBorder = Color(0xFFE0E0E0);
  static const success = Color(0xFF2E7D32);
}

class AppSpaces {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

ThemeData buildAppTheme() {
  // آمن على أحدث Flutter
  final base = ThemeData(
    useMaterial3: false,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: Colors.white,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      toolbarTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      bodyMedium: const TextStyle(fontSize: 14, color: AppColors.text),
      titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
      titleLarge: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.chipBg,
      side: const BorderSide(color: AppColors.chipBorder),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
  );
}

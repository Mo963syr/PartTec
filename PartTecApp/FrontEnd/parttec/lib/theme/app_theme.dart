import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color.fromARGB(255, 39, 92, 199);
  static const primaryDark = Color.fromARGB(255, 39, 92, 199);
  static const accent = Color(0xFF448AFF);
  static const bgGradientA = Color.fromARGB(255, 39, 92, 199);
  static const bgGradientB = Color.fromARGB(255, 60, 82, 244);
  static const bgGradientC = Color.fromARGB(255, 31, 139, 234);

  static const card = Colors.white;
  static const text = Color(0xFF212121);
  static const textWeak = Color(0xFF757575);
  static const chipBg = Colors.white;
  static const chipBorder = Color(0xFFE0E0E0);

  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFFA000);
  static const error = Color(0xFFD32F2F);
}

class AppSpaces {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppImages {
  static const String defaultPart =
      "https://res.cloudinary.com/dzjrgcxwt/image/upload/photo_2025-09-02_07-58-51_e8g6im.jpg";
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: false,
    fontFamily: "Tajawal",
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      bodyMedium: const TextStyle(fontSize: 14, color: AppColors.text),
      titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
      titleLarge: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.chipBg,
      side: const BorderSide(color: AppColors.chipBorder),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(AppSpaces.sm),
    ),
  );
}

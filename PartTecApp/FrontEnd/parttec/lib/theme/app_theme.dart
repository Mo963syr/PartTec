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
      "https://www.bing.com/images/search?view=detailV2&ccid=N12W6FwB&id=598B88BD3720C721F724C03B0D208C662404347C&thid=OIP.N12W6FwB8RT0ba5WrPcXEAHaE8&mediaurl=https%3a%2f%2fwww.mosoah.com%2fwp-content%2fuploads%2f2021%2f05%2f%d9%85%d9%88%d9%82%d8%b9-%d9%84%d9%85%d8%b9%d8%b1%d9%81%d8%a9-%d9%82%d8%b7%d8%b9-%d8%ba%d9%8a%d8%a7%d8%b1-%d8%a7%d9%84%d8%b3%d9%8a%d8%a7%d8%b1%d8%a7%d8%aa.jpg&cdnurl=https%3a%2f%2fth.bing.com%2fth%2fid%2fR.375d96e85c01f114f46dae56acf71710%3frik%3dfDQEJGaMIA07wA%26pid%3dImgRaw%26r%3d0&exph=800&expw=1200&q=%d8%b5%d9%88%d8%b1%d8%a9+%d9%82%d8%b7%d8%b9%d8%a9+%d8%ba%d9%8a%d8%a7%d8%b1&FORM=IRPRST&ck=465A8150B1B2D15531E37B9B83759F2E&selectedIndex=16&itb=0";
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

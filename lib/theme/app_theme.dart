import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Ultra-deep AMOLED backgrounds
  static const Color background = Color(0xFF070709);
  static const Color surface = Color(0xFF111116);
  static const Color surfaceCard = Color(0xFF16161D);
  static const Color surfaceBorder = Color(0xFF262633);

  // Vibrant Pop Neon Accents
  static const Color neonGreen = Color(0xFF00FF7F);       // Electric Spring / Charging
  static const Color cyberLime = Color(0xFF76FF03);       // Max speed 50W
  static const Color cyberCyan = Color(0xFF00E5FF);       // Voltage / Tech
  static const Color electricPurple = Color(0xFFD500F9);  // Current / Flow
  static const Color neonAmber = Color(0xFFFF9100);       // Warm / High power
  static const Color neonRed = Color(0xFFFF1744);         // Hot / Critical drain
  static const Color textMuted = Color(0xFF88889A);
  static const Color textBright = Color(0xFFFFFFFF);

  static LinearGradient neonGreenGlow = LinearGradient(
    colors: [neonGreen.withValues(alpha: 0.8), cyberLime.withValues(alpha: 0.3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = const LinearGradient(
    colors: [Color(0xFF181822), Color(0xFF111117)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.cyberCyan,
        tertiary: AppColors.electricPurple,
        surface: AppColors.surface,
        onSurface: AppColors.textBright,
        outline: AppColors.surfaceBorder,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textBright,
        displayColor: AppColors.textBright,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
        ),
      ),
      useMaterial3: true,
    );
  }
}

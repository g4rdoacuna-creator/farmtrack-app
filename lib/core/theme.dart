import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette — deep forest
  static const Color forestDeep = Color(0xFF0A2E1A);
  static const Color forestMid = Color(0xFF1B5E3B);
  static const Color forestLight = Color(0xFF2D7D52);
  static const Color forestMint = Color(0xFF52B788);
  static const Color forestPale = Color(0xFFD8F3DC);
  static const Color forestGhost = Color(0xFFF0FAF3);

  // Neutral palette — warm cream
  static const Color inkDark = Color(0xFF0F1A14);
  static const Color inkMid = Color(0xFF2C3E30);
  static const Color inkLight = Color(0xFF5A7063);
  static const Color inkGhost = Color(0xFF8FA897);
  static const Color cream = Color(0xFFFAF8F4);
  static const Color creamWarm = Color(0xFFF2EFE9);
  static const Color creamBorder = Color(0xFFE4DED4);
  static const Color white = Color(0xFFFFFFFF);

  // Accent palette
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberPale = Color(0xFFFEF3C7);
  static const Color amberDeep = Color(0xFFB45309);
  static const Color crimson = Color(0xFFDC2626);
  static const Color crimsonPale = Color(0xFFFEE2E2);
  static const Color sapphire = Color(0xFF2563EB);
  static const Color sapphirePale = Color(0xFFDBEAFE);
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetPale = Color(0xFFEDE9FE);

  // Animal colors
  static const Color pig = Color(0xFFF4845F);
  static const Color pigPale = Color(0xFFFFF0EB);
  static const Color chicken = Color(0xFFEAB308);
  static const Color chickenPale = Color(0xFFFEFCE8);
  static const Color goat = Color(0xFF0EA5E9);
  static const Color goatPale = Color(0xFFE0F5FF);
  static const Color cow = Color(0xFF8B5CF6);
  static const Color cowPale = Color(0xFFF5F0FF);
  static const Color duck = Color(0xFF10B981);
  static const Color duckPale = Color(0xFFECFDF5);
  static const Color custom = Color(0xFFEC4899);
  static const Color customPale = Color(0xFFFDF2F8);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forestMid,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.forestMid,
      secondary: AppColors.amber,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.inkDark,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 40, fontWeight: FontWeight.w800,
        color: AppColors.inkDark, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w800,
        color: AppColors.inkDark, letterSpacing: -1.0,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 26, fontWeight: FontWeight.w700,
        color: AppColors.inkDark, letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.inkDark,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: AppColors.inkDark,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.inkMid,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: AppColors.inkDark,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.inkLight,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.inkGhost, letterSpacing: 0.5,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: AppColors.inkDark, letterSpacing: 0.2,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.inkDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: AppColors.inkDark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.creamBorder, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.creamWarm,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.creamBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.creamBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.forestMint, width: 2),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkLight,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14, color: AppColors.inkGhost,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.forestMid,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );
}

// Reusable spacing constants
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// Reusable radius constants
class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 100;
}

// Animal color map
Color animalColor(String colorKey) {
  const map = {
    'pig': AppColors.pig,
    'chicken': AppColors.chicken,
    'goat': AppColors.goat,
    'cow': AppColors.cow,
    'duck': AppColors.duck,
    'custom': AppColors.custom,
  };
  return map[colorKey] ?? AppColors.custom;
}

Color animalPaleColor(String colorKey) {
  const map = {
    'pig': AppColors.pigPale,
    'chicken': AppColors.chickenPale,
    'goat': AppColors.goatPale,
    'cow': AppColors.cowPale,
    'duck': AppColors.duckPale,
    'custom': AppColors.customPale,
  };
  return map[colorKey] ?? AppColors.customPale;
}

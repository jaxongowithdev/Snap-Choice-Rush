import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF7A1F3D);
  static const Color secondaryColor = Color(0xFFC9A227);
  static const Color accentColor = Color(0xFFC9A227);
  static const Color ivory = Color(0xFFF7F1E3);
  static const Color ink = Color(0xFF1A1814);
  static const Color night = Color(0xFF120E10);
  static const Color deep = Color(0xFF1E1618);
  static const Color mist = Color(0xFFE6DFD0);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: secondaryColor,
      surface: ivory,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ivory,
      dividerColor: const Color(0x331A1814),
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF7A1F3D),
        foregroundColor: Color(0xFFF7F1E3),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x447A1F3D))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x447A1F3D))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A1F3D), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: ivory,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.workSans(fontWeight: FontWeight.w600, letterSpacing: 0.6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: secondaryColor,
      secondary: primaryColor,
      tertiary: secondaryColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F7F1E3),
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ivory,
        titleTextStyle: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: ivory),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFC9A227),
        foregroundColor: Color(0xFF1A1814),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F7F1E3))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F7F1E3))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A227), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.workSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Scores': const Color(0xFF7A1F3D),
      'Etudes': const Color(0xFFC9A227),
      'Methods': const Color(0xFF3D5A80),
      'Recordings': const Color(0xFF5B4B8A),
      'Duets': const Color(0xFF8A3A5A),
      'Theory': const Color(0xFF2F6F8A),
      'Rhythm': const Color(0xFFB45309),
      'Ensemble': const Color(0xFF2F7A5A),
      'Reeds': const Color(0xFF7A5A32),
      'Strings': const Color(0xFF4A5564),
      'Gear': const Color(0xFF3D4A5C),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF2F7A5A);
      case 'marked':
        return const Color(0xFFC9A227);
      case 'torn':
        return const Color(0xFF7A1F3D);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

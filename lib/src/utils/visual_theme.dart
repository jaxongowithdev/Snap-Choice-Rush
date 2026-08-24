import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF5C1228);
  static const Color secondaryColor = Color(0xFFD4AF37);
  static const Color accentColor = Color(0xFFF2C14E);
  static const Color cream = Color(0xFFF3E6C8);
  static const Color velvet = Color(0xFF2A0A14);
  static const Color ink = Color(0xFF1A1012);
  static const Color night = Color(0xFF14080C);
  static const Color deep = Color(0xFF1E0C12);
  static const Color mist = Color(0xFFE8D9B8);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: cream,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      dividerColor: const Color(0x445C1228),
      textTheme: GoogleFonts.libreFranklinTextTheme(ThemeData.light().textTheme).apply(
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
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFD4AF37),
        foregroundColor: Color(0xFF2A0A14),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x445C1228))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x445C1228))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C1228), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F3E6C8),
      textTheme: GoogleFonts.libreFranklinTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cream,
        titleTextStyle: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: cream),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFD4AF37),
        foregroundColor: Color(0xFF14080C),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F3E6C8))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F3E6C8))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: velvet,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Scripts': const Color(0xFF5C1228),
      'Roles': const Color(0xFFD4AF37),
      'Props': const Color(0xFF8A5A32),
      'Costumes': const Color(0xFF7A3A5A),
      'Lighting': const Color(0xFFF2C14E),
      'Sound': const Color(0xFF3D5A80),
      'Sets': const Color(0xFF4A6248),
      'Makeup': const Color(0xFF8A4A62),
      'Music': const Color(0xFF5B4B8A),
      'Blocking': const Color(0xFF4A5564),
      'Playbills': const Color(0xFF6B4A2A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF4A6248);
      case 'marked':
        return const Color(0xFFD4AF37);
      case 'worn':
        return const Color(0xFF5C1228);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF0E3A6B);
  static const Color secondaryColor = Color(0xFF7EC8E3);
  static const Color accentColor = Color(0xFFE8C547);
  static const Color vellum = Color(0xFFE8E4D8);
  static const Color plate = Color(0xFFF4F1E8);
  static const Color ink = Color(0xFF122033);
  static const Color cyan = Color(0xFF7EC8E3);
  static const Color night = Color(0xFF08182C);
  static const Color deep = Color(0xFF0C2240);
  static const Color mist = Color(0xFFD4D0C4);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: vellum,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: vellum,
      dividerColor: const Color(0x330E3A6B),
      textTheme: GoogleFonts.sourceSerif4TextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFF4F1E8),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.barlowCondensed(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 2, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF0E3A6B),
        foregroundColor: Color(0xFFE8E4D8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x440E3A6B))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x440E3A6B))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0E3A6B), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: vellum,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.barlowCondensed(fontWeight: FontWeight.w700, letterSpacing: 1.4, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: secondaryColor,
      secondary: accentColor,
      tertiary: primaryColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x337EC8E3),
      textTheme: GoogleFonts.sourceSerif4TextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: cyan,
        displayColor: vellum,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF102848),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cyan,
        titleTextStyle: GoogleFonts.barlowCondensed(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 2, color: cyan),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF7EC8E3),
        foregroundColor: Color(0xFF08182C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x557EC8E3))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x557EC8E3))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7EC8E3), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.barlowCondensed(fontWeight: FontWeight.w700, letterSpacing: 1.4, fontSize: 16),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Plans': const Color(0xFF7EC8E3),
      'Sections': const Color(0xFF0E3A6B),
      'Elevations': const Color(0xFF3A6A8A),
      'Details': const Color(0xFFE8C547),
      'Site': const Color(0xFF4A7A5A),
      'Models': const Color(0xFF8A6A4A),
      'Tools': const Color(0xFF5A5A5A),
      'Paper': const Color(0xFFD4D0C4),
      'Ink': const Color(0xFF122033),
      'Notes': const Color(0xFFC4A35A),
      'Critique': const Color(0xFFC45A3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'draft':
        return const Color(0xFF7EC8E3);
      case 'inked':
        return const Color(0xFF0E3A6B);
      case 'smudged':
        return const Color(0xFFC45A3A);
      case 'filed':
        return const Color(0xFFE8C547);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

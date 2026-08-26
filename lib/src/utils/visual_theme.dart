import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF6B4C9A);
  static const Color secondaryColor = Color(0xFFE8C547);
  static const Color accentColor = Color(0xFF7EC8E3);
  static const Color voidNavy = Color(0xFF0B1026);
  static const Color nebula = Color(0xFF2A1B4A);
  static const Color chart = Color(0xFFE6E0F0);
  static const Color ink = Color(0xFF16122A);
  static const Color night = Color(0xFF070A18);
  static const Color deep = Color(0xFF12182E);
  static const Color mist = Color(0xFFC8C0D8);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: chart,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: chart,
      dividerColor: const Color(0x336B4C9A),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFF4F0FA),
        margin: EdgeInsets.zero,
        shape: StadiumBorder(),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2.2, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF6B4C9A),
        foregroundColor: Color(0xFFE8C547),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F0FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0x666B4C9A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0x666B4C9A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF6B4C9A), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w700, letterSpacing: 1.4, fontSize: 13),
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
      dividerColor: const Color(0x33E8C547),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1A1630),
        margin: EdgeInsets.zero,
        shape: StadiumBorder(),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: chart,
        titleTextStyle: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2.2, color: chart),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE8C547),
        foregroundColor: Color(0xFF0B1026),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0x55E8C547))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0x55E8C547))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE8C547), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: voidNavy,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w700, letterSpacing: 1.4, fontSize: 13),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Planet': const Color(0xFFE8C547),
      'Star': const Color(0xFF7EC8E3),
      'Moon': const Color(0xFFC8C0D8),
      'Galaxy': const Color(0xFF6B4C9A),
      'Nebula': const Color(0xFFC45A9A),
      'Comet': const Color(0xFF7EC8E3),
      'Constellation': const Color(0xFFE8C547),
      'Myth': const Color(0xFFB08C5A),
      'Number': const Color(0xFF5A8A7A),
      'Voyage': const Color(0xFF4A6A9A),
      'Teacher': const Color(0xFF8A6A4A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return const Color(0xFF7EC8E3);
      case 'recalled':
        return const Color(0xFFE8C547);
      case 'faded':
        return const Color(0xFFC45A9A);
      case 'filed':
        return const Color(0xFF6B4C9A);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

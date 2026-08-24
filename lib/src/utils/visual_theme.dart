import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF3D5A3A);
  static const Color secondaryColor = Color(0xFFB85C38);
  static const Color accentColor = Color(0xFF8FA36A);
  static const Color cream = Color(0xFFF2EBD8);
  static const Color bark = Color(0xFF3A2A1E);
  static const Color ink = Color(0xFF1E1A14);
  static const Color night = Color(0xFF14110C);
  static const Color deep = Color(0xFF1C1812);
  static const Color mist = Color(0xFFE4D9C2);

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
      dividerColor: const Color(0x333D5A3A),
      textTheme: GoogleFonts.nunitoSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xAAF7F1E4),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFB85C38),
        foregroundColor: Color(0xFFF2EBD8),
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x443D5A3A))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x443D5A3A))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3D5A3A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: accentColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F2EBD8),
      textTheme: GoogleFonts.nunitoSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0x221C1812),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cream,
        titleTextStyle: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: cream),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFB85C38),
        foregroundColor: Color(0xFFF2EBD8),
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F2EBD8))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F2EBD8))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8FA36A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Leaves': const Color(0xFF3D5A3A),
      'Flowers': const Color(0xFFB85C38),
      'Bark': const Color(0xFF6B4A32),
      'Seeds': const Color(0xFF8FA36A),
      'Fungi': const Color(0xFF8A5A4A),
      'Insects': const Color(0xFF5A6B3A),
      'Rocks': const Color(0xFF6A6256),
      'Water': const Color(0xFF3D5A6A),
      'Weather': const Color(0xFF7A6A4A),
      'Trails': const Color(0xFF4A5A3A),
      'Tools': const Color(0xFF5A4A3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF3D5A3A);
      case 'pressed':
        return const Color(0xFF8FA36A);
      case 'brittle':
        return const Color(0xFFB85C38);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

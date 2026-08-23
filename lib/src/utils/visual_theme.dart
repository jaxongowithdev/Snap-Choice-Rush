import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF0E7C7B);
  static const Color secondaryColor = Color(0xFFF26B2B);
  static const Color accentColor = Color(0xFF0E7C7B);
  static const Color graphite = Color(0xFF16181D);
  static const Color grid = Color(0xFFF3F5F4);
  static const Color night = Color(0xFF0E1014);
  static const Color deep = Color(0xFF1A1E24);
  static const Color ink = Color(0xFF16181D);
  static const Color mist = Color(0xFFD9DEDC);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      surface: grid,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: grid,
      dividerColor: const Color(0x2216181D),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0x2216181D)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF26B2B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0x3316181D))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0x3316181D))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x22FFFFFF),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0x22FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF26B2B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF222830),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Glassware': const Color(0xFF0E7C7B),
      'Specimens': const Color(0xFF2F7A5A),
      'Tools': const Color(0xFF4A5564),
      'Sensors': const Color(0xFF2F6F8A),
      'Slides': const Color(0xFF6A4C93),
      'Models': const Color(0xFFF26B2B),
      'Worksheets': const Color(0xFFB45309),
      'Safety': const Color(0xFFD94F3D),
      'Kits': const Color(0xFF0E7C7B),
      'Notes': const Color(0xFF5B4B8A),
      'Devices': const Color(0xFF3D4A5C),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF0E7C7B);
      case 'in use':
        return const Color(0xFFF26B2B);
      case 'dirty':
        return const Color(0xFFD94F3D);
      case 'stored':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

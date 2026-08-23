import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF9E1B12);
  static const Color secondaryColor = Color(0xFF15233B);
  static const Color accentColor = Color(0xFFB8923A);
  static const Color paper = Color(0xFFF4EFE4);
  static const Color rule = Color(0x3315233B);
  static const Color night = Color(0xFF0E1522);
  static const Color deep = Color(0xFF162033);
  static const Color ink = Color(0xFF15233B);
  static const Color mist = Color(0xFFE4DCCB);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: secondaryColor,
      brightness: Brightness.light,
      primary: secondaryColor,
      secondary: primaryColor,
      tertiary: accentColor,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      dividerColor: rule,
      textTheme: GoogleFonts.ibmPlexSansTextTheme(ThemeData.light().textTheme).apply(
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
        backgroundColor: paper,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.libreBaskerville(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF9E1B12),
        foregroundColor: Color(0xFFF4EFE4),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x66FFFFFF),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x4415233B))),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x4415233B))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: secondaryColor,
      brightness: Brightness.dark,
      primary: accentColor,
      secondary: primaryColor,
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F4EFE4),
      textTheme: GoogleFonts.ibmPlexSansTextTheme(ThemeData.dark().textTheme),
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
        backgroundColor: night,
        foregroundColor: paper,
        titleTextStyle: GoogleFonts.libreBaskerville(fontSize: 20, fontWeight: FontWeight.w700, color: paper),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF9E1B12),
        foregroundColor: Color(0xFFF4EFE4),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4EFE4))),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4EFE4))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accentColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Past papers': const Color(0xFF9E1B12),
      'Flash decks': const Color(0xFFB8923A),
      'Notes': const Color(0xFF15233B),
      'Formulae': const Color(0xFF2F6F8A),
      'Audio': const Color(0xFF6A4C93),
      'Essays': const Color(0xFF7A4A2A),
      'Labs': const Color(0xFF2F7A5A),
      'Maps': const Color(0xFF3D5A80),
      'Vocab': const Color(0xFF8A3A5A),
      'Rubrics': const Color(0xFFB45309),
      'Devices': const Color(0xFF4A5564),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF2F7A5A);
      case 'drilling':
        return const Color(0xFFB8923A);
      case 'worn':
        return const Color(0xFF9E1B12);
      case 'shelved':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF1B365D);
  static const Color secondaryColor = Color(0xFFC44536);
  static const Color accentColor = Color(0xFF7BA3C9);
  static const Color manila = Color(0xFFF3E6C4);
  static const Color paper = Color(0xFFFAF3E3);
  static const Color ink = Color(0xFF1A1A18);
  static const Color night = Color(0xFF101820);
  static const Color deep = Color(0xFF162230);
  static const Color rule = Color(0xFF7BA3C9);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: manila,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: manila,
      dividerColor: const Color(0x331B365D),
      textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFFAF3E3),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.literata(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: Color(0xFFC44536),
        foregroundColor: Color(0xFFFAF3E3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x441B365D))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x441B365D))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1B365D), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          textStyle: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700, letterSpacing: 0.3),
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
      dividerColor: const Color(0x33F3E6C4),
      textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0x22162330),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: manila,
        titleTextStyle: GoogleFonts.literata(fontSize: 22, fontWeight: FontWeight.w700, color: manila),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: Color(0xFFC44536),
        foregroundColor: Color(0xFFFAF3E3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F3E6C4))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F3E6C4))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7BA3C9), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          textStyle: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Nouns': const Color(0xFF1B365D),
      'Verbs': const Color(0xFFC44536),
      'Roots': const Color(0xFF3D6B4A),
      'Prefixes': const Color(0xFF7BA3C9),
      'Idioms': const Color(0xFF8A4A62),
      'Cognates': const Color(0xFF6B5A3A),
      'Spelling': const Color(0xFF4A6270),
      'Grammar': const Color(0xFF5B4B8A),
      'Quotes': const Color(0xFF7A5A32),
      'Sets': const Color(0xFF2F5C6E),
      'Field': const Color(0xFF4A6248),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF3D6B4A);
      case 'dog-eared':
        return const Color(0xFFC44536);
      case 'faded':
        return const Color(0xFF7BA3C9);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

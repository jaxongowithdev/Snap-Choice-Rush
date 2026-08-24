import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF2C4A3C);
  static const Color secondaryColor = Color(0xFFB33A2B);
  static const Color accentColor = Color(0xFFC4A35A);
  static const Color oak = Color(0xFFC4A574);
  static const Color manila = Color(0xFFE8D5A3);
  static const Color paper = Color(0xFFF6EEDC);
  static const Color ink = Color(0xFF1C1814);
  static const Color night = Color(0xFF141210);
  static const Color deep = Color(0xFF1C1916);
  static const Color mist = Color(0xFFE4D8C0);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      dividerColor: const Color(0x332C4A3C),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFE8D5A3),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.libreBaskerville(fontSize: 20, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFB33A2B),
        foregroundColor: Color(0xFFF6EEDC),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFE8D5A3),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0x662C4A3C))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0x662C4A3C))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF2C4A3C), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 0.4),
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
      tertiary: oak,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33C4A35A),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF26211C),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: paper,
        titleTextStyle: GoogleFonts.libreBaskerville(fontSize: 20, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: paper),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFB33A2B),
        foregroundColor: Color(0xFFF6EEDC),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF26211C),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0x55C4A35A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0x55C4A35A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFC4A35A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: paper,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Picture': const Color(0xFFB33A2B),
      'Chapter': const Color(0xFF2C4A3C),
      'Nonfiction': const Color(0xFF3D5C7A),
      'Poetry': const Color(0xFF7A4A6A),
      'Graphic': const Color(0xFFC4A35A),
      'Biography': const Color(0xFF6A5A3A),
      'Folktale': const Color(0xFF5A7A4A),
      'Science': const Color(0xFF3A6A6A),
      'History': const Color(0xFF8A5A3A),
      'Series': const Color(0xFF4A5A8A),
      'Teacher': const Color(0xFF5A4A3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return const Color(0xFF5A7A4A);
      case 'loaned':
        return const Color(0xFF3D5C7A);
      case 'worn':
        return const Color(0xFFB33A2B);
      case 'filed':
        return const Color(0xFFC4A35A);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

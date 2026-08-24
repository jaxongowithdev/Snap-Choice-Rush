import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF0E4A5A);
  static const Color secondaryColor = Color(0xFFE07A5F);
  static const Color accentColor = Color(0xFFC6A45A);
  static const Color sand = Color(0xFFF4E6CE);
  static const Color foam = Color(0xFFE8F0EE);
  static const Color ink = Color(0xFF1A2A32);
  static const Color night = Color(0xFF0B1C22);
  static const Color deep = Color(0xFF122830);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: sand,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: sand,
      dividerColor: const Color(0x330E4A5A),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: foam.withValues(alpha: 0.55),
        margin: EdgeInsets.zero,
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE07A5F),
        foregroundColor: Color(0xFFF4E6CE),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x440E4A5A))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x440E4A5A))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0E4A5A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: sand,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, letterSpacing: 0.6),
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
      dividerColor: const Color(0x33F4E6CE),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0x221E3A42),
        margin: EdgeInsets.zero,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: sand,
        titleTextStyle: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, color: sand),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE07A5F),
        foregroundColor: Color(0xFF0B1C22),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4E6CE))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4E6CE))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE07A5F), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Continents': const Color(0xFF0E4A5A),
      'Capitals': const Color(0xFFE07A5F),
      'Rivers': const Color(0xFF2F6F8A),
      'Ranges': const Color(0xFF6B5A3A),
      'Coasts': const Color(0xFF3D7A6A),
      'Climate': const Color(0xFFC6A45A),
      'Cultures': const Color(0xFF8A4A62),
      'Trade': const Color(0xFF4A5564),
      'Maps': const Color(0xFF1F5C6E),
      'Globes': const Color(0xFF3A6B8A),
      'Field': const Color(0xFF6A7A3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF2F7A5A);
      case 'folded':
        return const Color(0xFFC6A45A);
      case 'torn':
        return const Color(0xFFE07A5F);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

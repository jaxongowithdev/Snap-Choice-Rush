import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color secondaryColor = Color(0xFFF15A24);
  static const Color accentColor = Color(0xFFC4D63A);
  static const Color maple = Color(0xFFE6C07A);
  static const Color track = Color(0xFFC73E3A);
  static const Color court = Color(0xFFF3EEE4);
  static const Color ink = Color(0xFF14202C);
  static const Color night = Color(0xFF0E141C);
  static const Color deep = Color(0xFF16202C);
  static const Color mist = Color(0xFFD9D0C2);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: court,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: court,
      dividerColor: const Color(0x331E3A5F),
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFE6C07A),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(22)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.oswald(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF15A24),
        foregroundColor: Color(0xFFF3EEE4),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFEDE6D8),
        border: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0x661E3A5F))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0x661E3A5F))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0xFF1E3A5F), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: court,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(14))),
          textStyle: GoogleFonts.oswald(fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
      tertiary: maple,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33C4D63A),
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1C2836),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(22)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: court,
        titleTextStyle: GoogleFonts.oswald(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: court),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF15A24),
        foregroundColor: Color(0xFFF3EEE4),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1C2836),
        border: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0x55C4D63A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0x55C4D63A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)), borderSide: BorderSide(color: Color(0xFFC4D63A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: court,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(14))),
          textStyle: GoogleFonts.oswald(fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Ball': const Color(0xFFF15A24),
      'Cone': const Color(0xFFF15A24),
      'Pinnie': const Color(0xFF1E3A5F),
      'Rope': const Color(0xFFC4D63A),
      'Mat': const Color(0xFF3A7A6A),
      'Hula': const Color(0xFFD45A8A),
      'Bat': const Color(0xFF8A5A3A),
      'Net': const Color(0xFF3A6A8A),
      'Whistle': const Color(0xFFC73E3A),
      'Timer': const Color(0xFF5A5A8A),
      'First-aid': const Color(0xFFC73E3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return const Color(0xFF3A7A6A);
      case 'out':
        return const Color(0xFF1E3A5F);
      case 'worn':
        return const Color(0xFFF15A24);
      case 'stored':
        return const Color(0xFFC4D63A);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

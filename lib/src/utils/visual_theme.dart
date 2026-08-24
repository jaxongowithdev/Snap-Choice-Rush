import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF4A90C8);
  static const Color secondaryColor = Color(0xFFE24B3D);
  static const Color accentColor = Color(0xFFF0C020);
  static const Color grape = Color(0xFF7B5EA7);
  static const Color grass = Color(0xFF5AAB5A);
  static const Color maple = Color(0xFFD7A56A);
  static const Color wall = Color(0xFFF4EFE6);
  static const Color ink = Color(0xFF2C241C);
  static const Color night = Color(0xFF161310);
  static const Color deep = Color(0xFF1E1A16);
  static const Color mist = Color(0xFFE8DFD2);
  static const Color label = Color(0xFFFFFDF8);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: wall,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: wall,
      dividerColor: const Color(0x332C241C),
      textTheme: GoogleFonts.literataTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFF7F1E8),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE24B3D),
        foregroundColor: Color(0xFFFFFDF8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x44D7A56A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x44D7A56A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4A90C8), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: label,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, letterSpacing: 0.2),
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
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F4EFE6),
      textTheme: GoogleFonts.literataTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF26211C),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: wall,
        titleTextStyle: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, color: wall),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE24B3D),
        foregroundColor: Color(0xFFFFFDF8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF26211C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x44F4EFE6))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x44F4EFE6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4A90C8), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: label,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Blocks': const Color(0xFFE24B3D),
      'Art': const Color(0xFFF0C020),
      'Dramatic': const Color(0xFF7B5EA7),
      'Sensory': const Color(0xFF4A90C8),
      'Literacy': const Color(0xFF5AAB5A),
      'Math': const Color(0xFFD7A56A),
      'Science': const Color(0xFF3D8B8B),
      'Outdoors': const Color(0xFF6B8F3A),
      'Quiet': const Color(0xFF8A7A6A),
      'Music': const Color(0xFFC45A7A),
      'Puzzle': const Color(0xFF5A7ABF),
      'Other': const Color(0xFF8A8074),
    };
    return colors[category] ?? const Color(0xFF8A8074);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'open':
        return const Color(0xFF5AAB5A);
      case 'packed':
        return const Color(0xFF4A90C8);
      case 'worn':
        return const Color(0xFFE24B3D);
      case 'labeled':
        return const Color(0xFFF0C020);
      default:
        return const Color(0xFF8A8074);
    }
  }
}

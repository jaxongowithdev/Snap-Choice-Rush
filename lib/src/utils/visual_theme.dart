import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF1B2A4A);
  static const Color secondaryColor = Color(0xFFC45C26);
  static const Color accentColor = Color(0xFFD4A84B);
  static const Color cream = Color(0xFFF7F1E6);
  static const Color mist = Color(0xFFE8DFD0);
  static const Color night = Color(0xFF0E1524);
  static const Color deep = Color(0xFF162033);
  static const Color ink = Color(0xFF1B2A4A);

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
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFFFFFBF4),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x221B2A4A)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: cream,
        titleTextStyle: GoogleFonts.literata(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: cream,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: primaryColor,
        indicatorColor: secondaryColor,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: cream),
        ),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Color(0xFFF7F1E6))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFBF4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x221B2A4A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x221B2A4A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: secondaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF9BB0D4),
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: deep,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.literata(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: deep,
        indicatorColor: secondaryColor.withValues(alpha: 0.8),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C2A42),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF9BB0D4), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Nibs': const Color(0xFFD4A84B),
      'Inks': const Color(0xFFC45C26),
      'Pens': const Color(0xFF1B2A4A),
      'Paper': const Color(0xFF8A7A5A),
      'Blotters': const Color(0xFF6A4A3A),
      'Convertors': const Color(0xFF4A6FA5),
      'Cleaning': const Color(0xFF3D6B5A),
      'Cases': const Color(0xFF5B4A7A),
      'Samples': const Color(0xFF8A4A6A),
      'Other': const Color(0xFF6A746C),
    };
    return colors[category] ?? const Color(0xFF6A746C);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sealed':
        return const Color(0xFF3D6B5A);
      case 'opened':
        return const Color(0xFFC45C26);
      case 'diluted':
        return const Color(0xFF4A6FA5);
      case 'dry':
        return const Color(0xFF8A4A3D);
      default:
        return const Color(0xFF6A746C);
    }
  }
}

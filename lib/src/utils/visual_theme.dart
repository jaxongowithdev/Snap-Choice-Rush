import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF12161C);
  static const Color secondaryColor = Color(0xFF9BC53D);
  static const Color accentColor = Color(0xFFE6A23C);
  static const Color ice = Color(0xFFEEF2F4);
  static const Color mist = Color(0xFFD8DEE4);
  static const Color night = Color(0xFF0A0D11);
  static const Color deep = Color(0xFF171C24);
  static const Color ink = Color(0xFF161B22);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: ice,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ice,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0x1412161C)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ice,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Color(0xFF9BC53D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: primaryColor,
        indicatorColor: const Color(0xFF2A3220),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Color(0xFF9BC53D))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x2212161C))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x2212161C))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: secondaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700),
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
      tertiary: secondaryColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0x22FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: night,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF9BC53D),
        foregroundColor: Color(0xFF12161C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: deep,
        indicatorColor: const Color(0xFF2A3220),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C232E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: secondaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: const Color(0xFF12161C),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Spirits': const Color(0xFFE6A23C),
      'Liqueurs': const Color(0xFFC45C7A),
      'Bitters': const Color(0xFFC23B2E),
      'Mixers': const Color(0xFF4A90A4),
      'Citrus': const Color(0xFF9BC53D),
      'Garnish': const Color(0xFF3D8B6E),
      'Glassware': const Color(0xFF6A8CA8),
      'Tools': const Color(0xFF5A5348),
      'Syrups': const Color(0xFFD4894A),
      'Amaro': const Color(0xFF6B3A2A),
      'Wine': const Color(0xFF7A2E44),
      'Other': const Color(0xFF6A746C),
    };
    return colors[category] ?? const Color(0xFF6A746C);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sealed':
        return const Color(0xFF3D8B6E);
      case 'opened':
        return const Color(0xFF9BC53D);
      case 'low':
        return const Color(0xFFE6A23C);
      case 'empty':
        return const Color(0xFFC23B2E);
      default:
        return const Color(0xFF6A746C);
    }
  }
}

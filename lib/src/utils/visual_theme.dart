import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFFC23A2C);
  static const Color secondaryColor = Color(0xFF31476B);
  static const Color accentColor = Color(0xFFC23A2C);
  static const Color washi = Color(0xFFF4EFE4);
  static const Color fiber = Color(0xFFE8E0D0);
  static const Color ink = Color(0xFF1B1814);
  static const Color night = Color(0xFF14110E);
  static const Color deep = Color(0xFF1E1A16);
  static const Color bamboo = Color(0xFF5C6B45);
  static const Color rod = Color(0xFF7A6248);

  static const _tag = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(22)),
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: bamboo,
      surface: washi,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: washi,
      dividerColor: const Color(0x331B1814),
      textTheme: GoogleFonts.figtreeTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0x66FFFFFF),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.spectral(fontSize: 24, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFC23A2C),
        foregroundColor: Color(0xFFF4EFE4),
        shape: _tag,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x44C23A2C))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x44C23A2C))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC23A2C), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: washi,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: _tag,
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w600, letterSpacing: 0.4),
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
      tertiary: bamboo,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33F4EFE4),
      textTheme: GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0x221E1A16),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: washi,
        titleTextStyle: GoogleFonts.spectral(fontSize: 24, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: washi),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFC23A2C),
        foregroundColor: Color(0xFFF4EFE4),
        shape: _tag,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4EFE4))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55F4EFE4))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC23A2C), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: washi,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: _tag,
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Sonnets': const Color(0xFFC23A2C),
      'Haiku': const Color(0xFF31476B),
      'Free verse': const Color(0xFF5C6B45),
      'Spoken': const Color(0xFF8A4A32),
      'Chorus': const Color(0xFF6B4A7A),
      'Drama': const Color(0xFF7A3A4A),
      'Forms': const Color(0xFF4A6270),
      'Devices': const Color(0xFF7A6248),
      'Journals': const Color(0xFF3D5A4A),
      'Translation': const Color(0xFF2F5C6E),
      'Anthology': const Color(0xFF5A4A3A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clean':
        return const Color(0xFF5C6B45);
      case 'smudged':
        return const Color(0xFF7A6248);
      case 'creased':
        return const Color(0xFFC23A2C);
      case 'filed':
        return const Color(0xFF6A6256);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

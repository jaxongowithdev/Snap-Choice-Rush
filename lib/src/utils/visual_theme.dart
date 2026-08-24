import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFFE8943A);
  static const Color secondaryColor = Color(0xFF8FA3A8);
  static const Color accentColor = Color(0xFFE8C547);
  static const Color fog = Color(0xFF0C0A08);
  static const Color deep = Color(0xFF161310);
  static const Color paper = Color(0xFFEDE8DC);
  static const Color print = Color(0xFFF6F1E6);
  static const Color ink = Color(0xFF1A1612);
  static const Color hypo = Color(0xFFC9C2B4);
  static const Color night = Color(0xFF090806);

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
      dividerColor: const Color(0x331A1612),
      textTheme: GoogleFonts.frauncesTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFF6F1E6),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.ibmPlexMono(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE8943A),
        foregroundColor: Color(0xFF0C0A08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x441A1612))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x441A1612))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE8943A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: fog,
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
      scaffoldBackgroundColor: fog,
      dividerColor: const Color(0x33E8943A),
      textTheme: GoogleFonts.frauncesTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: hypo,
        displayColor: print,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF1C1814),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        titleTextStyle: GoogleFonts.ibmPlexMono(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: primaryColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE8943A),
        foregroundColor: Color(0xFF0C0A08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55E8943A))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55E8943A))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE8943A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: fog,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Negatives': const Color(0xFF6B6560),
      'Prints': const Color(0xFFEDE8DC),
      'Contacts': const Color(0xFFC9C2B4),
      'Papers': const Color(0xFFE8C547),
      'Chemistry': const Color(0xFFE8943A),
      'Cameras': const Color(0xFF8FA3A8),
      'Lenses': const Color(0xFF5A6A72),
      'Filters': const Color(0xFFC45A3A),
      'Lights': const Color(0xFFE8943A),
      'Tripods': const Color(0xFF4A4038),
      'Notes': const Color(0xFFA89060),
      'Other': const Color(0xFF7A746C),
    };
    return colors[category] ?? const Color(0xFF7A746C);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'wet':
        return const Color(0xFF8FA3A8);
      case 'drying':
        return const Color(0xFFE8C547);
      case 'flat':
        return const Color(0xFFEDE8DC);
      case 'filed':
        return const Color(0xFFE8943A);
      default:
        return const Color(0xFF7A746C);
    }
  }
}

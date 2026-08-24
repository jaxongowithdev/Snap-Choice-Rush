import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF8B2E2E);
  static const Color secondaryColor = Color(0xFFC4A35A);
  static const Color accentColor = Color(0xFF3D4450);
  static const Color parchment = Color(0xFFEFE6D2);
  static const Color plaque = Color(0xFFF7F1E2);
  static const Color ink = Color(0xFF1F1A16);
  static const Color slate = Color(0xFF3D4450);
  static const Color night = Color(0xFF141210);
  static const Color deep = Color(0xFF1C1916);
  static const Color mist = Color(0xFFE4D9C4);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: parchment,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: parchment,
      dividerColor: const Color(0x338B2E2E),
      textTheme: GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFFF7F1E2),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF8B2E2E),
        foregroundColor: Color(0xFFEFE6D2),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x448B2E2E))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x448B2E2E))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B2E2E), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: parchment,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: secondaryColor,
      secondary: primaryColor,
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33C4A35A),
      textTheme: GoogleFonts.publicSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF221E1A),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: parchment,
        titleTextStyle: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: parchment),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF8B2E2E),
        foregroundColor: Color(0xFFEFE6D2),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55C4A35A))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x55C4A35A))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC4A35A), width: 1.6)),
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Ancient': const Color(0xFFC4A35A),
      'Medieval': const Color(0xFF8B2E2E),
      'Early Modern': const Color(0xFF3D4450),
      'Revolution': const Color(0xFFB33A2B),
      'Industry': const Color(0xFF5A6A72),
      'Wars': const Color(0xFF4A3A32),
      'Civil Rights': const Color(0xFF6A5A8A),
      'Local': const Color(0xFF5A7A4A),
      'Maps': const Color(0xFF3A5A6A),
      'Speeches': const Color(0xFF8A6A3A),
      'Artifacts': const Color(0xFF7A5A4A),
      'Other': const Color(0xFF6A6256),
    };
    return colors[category] ?? const Color(0xFF6A6256);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fragile':
        return const Color(0xFF8B2E2E);
      case 'stable':
        return const Color(0xFF5A7A4A);
      case 'mounted':
        return const Color(0xFFC4A35A);
      case 'filed':
        return const Color(0xFF3D4450);
      default:
        return const Color(0xFF6A6256);
    }
  }
}

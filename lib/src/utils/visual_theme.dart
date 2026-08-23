import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF1E3D34);
  static const Color secondaryColor = Color(0xFFC4532C);
  static const Color accentColor = Color(0xFFE8B84A);
  static const Color parchment = Color(0xFFF6F0E6);
  static const Color sand = Color(0xFFE8DFD0);
  static const Color night = Color(0xFF121A17);
  static const Color deep = Color(0xFF1A2823);
  static const Color ink = Color(0xFF2A241C);
  static const Color mist = sand;

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
      textTheme: GoogleFonts.lexendTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x22C4532C)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: parchment,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 74,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0x331E3D34),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600, color: primaryColor),
        ),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Color(0xFFC4532C))),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sand,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600),
        secondaryLabelStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0x33C4532C))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0x33C4532C))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: parchment,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
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
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x22FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: night,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFC4532C),
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 74,
        backgroundColor: deep,
        indicatorColor: const Color(0x33E8B84A),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF22352E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: accentColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Readers': const Color(0xFF1E3D34),
      'Workbooks': const Color(0xFFC4532C),
      'Flashcards': const Color(0xFFE8B84A),
      'Manipulatives': const Color(0xFF3E6B8A),
      'Art': const Color(0xFFB85C7A),
      'Science': const Color(0xFF2F7A5A),
      'Maps': const Color(0xFF6A4C93),
      'Stationery': const Color(0xFF8A6A3E),
      'Devices': const Color(0xFF4A5564),
      'Music': const Color(0xFF8B3A4A),
      'Games': const Color(0xFF3D7A6B),
      'Other': const Color(0xFF7A6E62),
    };
    return colors[category] ?? const Color(0xFF7A6E62);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF2F7A5A);
      case 'in use':
        return const Color(0xFFE8B84A);
      case 'worn':
        return const Color(0xFFC4532C);
      case 'retired':
        return const Color(0xFF7A6E62);
      default:
        return const Color(0xFF7A6E62);
    }
  }
}

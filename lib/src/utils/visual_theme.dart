import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Orbit Recall — a bright, rounded "bento" system.
/// Big radii, soft shadows, geometric headings, high-contrast pastel accents.
class VisualTheme {
  // ---- Core hues -------------------------------------------------------
  static const Color nova = Color(0xFF5B4BE8); // indigo — primary
  static const Color flare = Color(0xFFFF8A4C); // orange — secondary
  static const Color mint = Color(0xFF12B886); // teal — success / locked
  static const Color rose = Color(0xFFF0509B); // pink
  static const Color sun = Color(0xFFFFC53D); // amber
  static const Color sky = Color(0xFF3BA9F5); // blue
  static const Color plum = Color(0xFF8B5CF6); // violet

  // ---- Neutrals --------------------------------------------------------
  static const Color canvas = Color(0xFFF2F0FB); // app background (light)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color veil = Color(0xFFE9E5F9); // tinted fill
  static const Color ink = Color(0xFF1A1533);
  static const Color muted = Color(0xFF6E6791);

  static const Color night = Color(0xFF111024); // app background (dark)
  static const Color nightSurface = Color(0xFF1C1A36);
  static const Color nightVeil = Color(0xFF272348);
  static const Color nightInk = Color(0xFFF2F0FB);

  // ---- Radii -----------------------------------------------------------
  static const double rXL = 30;
  static const double rL = 24;
  static const double rM = 18;
  static const double rS = 14;

  static List<BoxShadow> softShadow(bool dark) => dark
      ? const [BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 8))]
      : const [BoxShadow(color: Color(0x14382C7A), blurRadius: 22, offset: Offset(0, 10))];

  static Color surfaceOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightSurface : surface;

  static Color veilOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightVeil : veil;

  static Color inkOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightInk : ink;

  static Color mutedOf(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? nightInk.withValues(alpha: 0.62)
      : muted;

  // ---- Type ------------------------------------------------------------
  static TextStyle display(double size, {Color? color, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.outfit(fontSize: size, fontWeight: w, height: 1.08, letterSpacing: -0.8, color: color);

  static TextStyle heading(double size, {Color? color, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.outfit(fontSize: size, fontWeight: w, height: 1.2, letterSpacing: -0.3, color: color);

  static TextStyle body(double size, {Color? color, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: w, height: 1.5, color: color);

  static TextStyle tag(double size, {Color? color, FontWeight w = FontWeight.w800}) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: w, letterSpacing: 0.9, color: color);

  // ---- Themes ----------------------------------------------------------
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: nova,
      brightness: Brightness.light,
      primary: nova,
      secondary: flare,
      tertiary: mint,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: const Color(0x1A5B4BE8),
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: ink, displayColor: ink),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rL)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: heading(24, color: ink, w: FontWeight.w700),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: nova,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        extendedPadding: EdgeInsets.symmetric(horizontal: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: veil,
        labelStyle: body(14, color: muted),
        hintStyle: body(14, color: muted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(rM), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rM), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: nova, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: nova,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: nova,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: Color(0x335B4BE8), width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nova,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: body(14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rL)),
        titleTextStyle: heading(20, color: ink, w: FontWeight.w700),
        contentTextStyle: body(15, color: muted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: nova),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: nova,
      brightness: Brightness.dark,
      primary: const Color(0xFF9C8CFF),
      secondary: flare,
      tertiary: mint,
      surface: nightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x339C8CFF),
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: nightInk, displayColor: nightInk),
      cardTheme: CardThemeData(
        elevation: 0,
        color: nightSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rL)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: nightInk,
        titleTextStyle: heading(24, color: nightInk, w: FontWeight.w700),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF9C8CFF),
        foregroundColor: Color(0xFF111024),
        shape: StadiumBorder(),
        extendedPadding: EdgeInsets.symmetric(horizontal: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nightVeil,
        labelStyle: body(14, color: nightInk.withValues(alpha: 0.6)),
        hintStyle: body(14, color: nightInk.withValues(alpha: 0.4)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(rM), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rM), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: Color(0xFF9C8CFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9C8CFF),
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9C8CFF),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: Color(0x559C8CFF), width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9C8CFF),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: nightVeil,
        contentTextStyle: body(14, color: nightInk),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: nightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rL)),
        titleTextStyle: heading(20, color: nightInk, w: FontWeight.w700),
        contentTextStyle: body(15, color: nightInk.withValues(alpha: 0.7)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF9C8CFF)),
    );
  }

  // ---- Domain colors ---------------------------------------------------

  /// Cue types used across Orbit Recall.
  static const List<String> cueTypes = [
    'Peg',
    'Journey',
    'Story',
    'Image',
    'Number',
    'Acronym',
    'Rhyme',
    'Chunk',
    'Link',
    'Sketch',
    'Sound',
    'Other',
  ];

  /// Recall levels, weakest first.
  static const List<String> recallLevels = ['Fresh', 'Shaky', 'Steady', 'Locked', 'Faded'];

  /// Mission tracks.
  static const List<String> tracks = [
    'Planets',
    'Moons',
    'Deep Sky',
    'Space Tech',
    'Physics',
    'Numbers',
    'Timeline',
    'General',
  ];

  static Color getCategoryColor(String category) {
    const map = {
      'Peg': nova,
      'Journey': sky,
      'Story': rose,
      'Image': flare,
      'Number': mint,
      'Acronym': plum,
      'Rhyme': sun,
      'Chunk': Color(0xFF4DBFA6),
      'Link': Color(0xFF6C7BF0),
      'Sketch': Color(0xFFEF7C8E),
      'Sound': Color(0xFF3FC1C9),
      'Other': muted,
    };
    return map[category] ?? muted;
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return sky;
      case 'shaky':
        return flare;
      case 'steady':
        return sun;
      case 'locked':
        return mint;
      case 'faded':
        return rose;
      default:
        return muted;
    }
  }

  /// 0.0 – 1.0 strength used for rings and bars.
  static double recallStrength(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return 0.25;
      case 'shaky':
        return 0.40;
      case 'steady':
        return 0.70;
      case 'locked':
        return 1.0;
      case 'faded':
        return 0.12;
      default:
        return 0.3;
    }
  }

  static IconData trackIcon(String track) {
    switch (track) {
      case 'Planets':
        return Icons.public_rounded;
      case 'Moons':
        return Icons.brightness_2_rounded;
      case 'Deep Sky':
        return Icons.auto_awesome_rounded;
      case 'Space Tech':
        return Icons.rocket_launch_rounded;
      case 'Physics':
        return Icons.science_rounded;
      case 'Numbers':
        return Icons.tag_rounded;
      case 'Timeline':
        return Icons.timeline_rounded;
      default:
        return Icons.workspaces_rounded;
    }
  }
}

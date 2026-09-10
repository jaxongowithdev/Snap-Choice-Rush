import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Live appearance. Config writes here so MaterialApp swaps theme without a restart.
class AppAppearance {
  static final ValueNotifier<ThemeMode> listenable = ValueNotifier(ThemeMode.system);

  static ThemeMode parse(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static void apply(String theme) {
    final next = parse(theme);
    if (listenable.value != next) listenable.value = next;
  }
}

/// Quietforge — a paper atelier.
/// Warm cream, charcoal, terracotta and forest. Serif display, hairline cards.
class VisualTheme {
  static const Color clay = Color(0xFFB85C38); // terracotta — primary
  static const Color moss = Color(0xFF3D6B4F); // forest — secondary
  static const Color inkBlue = Color(0xFF2C4A6E); // slate blue
  static const Color rust = Color(0xFF9A3412);
  static const Color ochre = Color(0xFFC7923E);
  static const Color sage = Color(0xFF6B8F71);
  static const Color wine = Color(0xFF8B3A4A);

  static const Color paper = Color(0xFFF6F0E6);
  static const Color surface = Color(0xFFFFFBF5);
  static const Color veil = Color(0xFFEDE4D4);
  static const Color ink = Color(0xFF1C1916);
  static const Color muted = Color(0xFF6B6258);

  static const Color night = Color(0xFF161310);
  static const Color nightSurface = Color(0xFF221E1A);
  static const Color nightVeil = Color(0xFF2C2722);
  static const Color nightInk = Color(0xFFF3EBE0);

  static const double rXL = 12;
  static const double rL = 10;
  static const double rM = 8;
  static const double rS = 6;

  static List<BoxShadow> softShadow(bool dark) => dark
      ? const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))]
      : const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))];

  static Color surfaceOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightSurface : surface;

  static Color veilOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightVeil : veil;

  static Color inkOf(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? nightInk : ink;

  static Color mutedOf(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? nightInk.withValues(alpha: 0.62)
      : muted;

  static TextStyle display(double size, {Color? color, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: w,
        height: 1.12,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle heading(double size, {Color? color, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: w,
        height: 1.25,
        letterSpacing: -0.15,
        color: color,
      );

  static TextStyle body(double size, {Color? color, FontWeight w = FontWeight.w400}) =>
      GoogleFonts.sourceSans3(fontSize: size, fontWeight: w, height: 1.45, color: color);

  static TextStyle tag(double size, {Color? color, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.sourceSans3(
        fontSize: size,
        fontWeight: w,
        letterSpacing: 1.1,
        color: color,
      );

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: clay,
      brightness: Brightness.light,
      primary: clay,
      secondary: moss,
      tertiary: ochre,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      dividerColor: const Color(0x332C241C),
      splashFactory: InkRipple.splashFactory,
      textTheme: GoogleFonts.sourceSans3TextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: ink, displayColor: ink),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rL),
          side: const BorderSide(color: Color(0x1A1C1916)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: heading(22, color: ink, w: FontWeight.w600),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: clay,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        extendedPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: veil,
        labelStyle: body(14, color: muted),
        hintStyle: body(14, color: muted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: Color(0x221C1916)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: Color(0x221C1916)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: clay, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: clay,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: clay,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: Color(0x55B85C38), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: clay,
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 15),
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
        titleTextStyle: heading(20, color: ink, w: FontWeight.w600),
        contentTextStyle: body(15, color: muted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: clay),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: clay,
      brightness: Brightness.dark,
      primary: const Color(0xFFE08A68),
      secondary: sage,
      tertiary: ochre,
      surface: nightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x33E08A68),
      splashFactory: InkRipple.splashFactory,
      textTheme: GoogleFonts.sourceSans3TextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: nightInk, displayColor: nightInk),
      cardTheme: CardThemeData(
        elevation: 0,
        color: nightSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rL),
          side: const BorderSide(color: Color(0x22E08A68)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: nightInk,
        titleTextStyle: heading(22, color: nightInk, w: FontWeight.w600),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFE08A68),
        foregroundColor: Color(0xFF161310),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        extendedPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nightVeil,
        labelStyle: body(14, color: nightInk.withValues(alpha: 0.6)),
        hintStyle: body(14, color: nightInk.withValues(alpha: 0.4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rM),
          borderSide: const BorderSide(color: Color(0xFFE08A68), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE08A68),
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE08A68),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: Color(0x55E08A68), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE08A68),
          textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700, fontSize: 15),
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
        titleTextStyle: heading(20, color: nightInk, w: FontWeight.w600),
        contentTextStyle: body(15, color: nightInk.withValues(alpha: 0.7)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFFE08A68)),
    );
  }

  /// Writing forms a recipe can take.
  static const List<String> cueTypes = [
    'Caption',
    'Hook',
    'Outline',
    'Scene',
    'Letter',
    'Lesson',
    'Product',
    'Poem',
    'Brief',
    'Journal',
    'Script',
    'Other',
  ];

  /// Draft stages, earliest first.
  static const List<String> recallLevels = ['Seed', 'Rough', 'Tuned', 'Ready', 'Shelved'];

  /// Crafts a workshop belongs to.
  static const List<String> tracks = [
    'Newsletter',
    'Product',
    'Classroom',
    'Fiction',
    'Social',
    'Personal',
    'Speech',
    'General',
  ];

  static Color getCategoryColor(String category) {
    const map = {
      'Caption': clay,
      'Hook': ochre,
      'Outline': inkBlue,
      'Scene': wine,
      'Letter': moss,
      'Lesson': sage,
      'Product': rust,
      'Poem': Color(0xFF7A5C9E),
      'Brief': inkBlue,
      'Journal': Color(0xFF5C7A6E),
      'Script': Color(0xFFC46B4A),
      'Other': muted,
    };
    return map[category] ?? muted;
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'seed':
        return inkBlue;
      case 'rough':
        return ochre;
      case 'tuned':
        return sage;
      case 'ready':
        return moss;
      case 'shelved':
        return wine;
      default:
        return muted;
    }
  }

  static double recallStrength(String condition) {
    switch (condition.toLowerCase()) {
      case 'seed':
        return 0.22;
      case 'rough':
        return 0.45;
      case 'tuned':
        return 0.72;
      case 'ready':
        return 1.0;
      case 'shelved':
        return 0.10;
      default:
        return 0.3;
    }
  }

  static IconData trackIcon(String track) {
    switch (track) {
      case 'Newsletter':
        return Icons.mail_outline_rounded;
      case 'Product':
        return Icons.storefront_outlined;
      case 'Classroom':
        return Icons.school_outlined;
      case 'Fiction':
        return Icons.auto_stories_outlined;
      case 'Social':
        return Icons.forum_outlined;
      case 'Personal':
        return Icons.favorite_border_rounded;
      case 'Speech':
        return Icons.record_voice_over_outlined;
      default:
        return Icons.edit_note_rounded;
    }
  }
}

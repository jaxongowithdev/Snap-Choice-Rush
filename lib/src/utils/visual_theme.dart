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

/// Kettleleaf — a celadon tea journal.
/// Steam-green ground, tea-amber accents. Literata display, Karla body.
class VisualTheme {
  static const Color clay = Color(0xFF2F6F62); // celadon — primary
  static const Color moss = Color(0xFFC4783A); // amber liquor — secondary
  static const Color inkBlue = Color(0xFF3D5A73);
  static const Color rust = Color(0xFF9A4A2A);
  static const Color ochre = Color(0xFFD4A056);
  static const Color sage = Color(0xFF5E8A72);
  static const Color wine = Color(0xFF8B4A5A);

  static const Color paper = Color(0xFFEEF3EF);
  static const Color surface = Color(0xFFF7FBF8);
  static const Color veil = Color(0xFFDCE8E2);
  static const Color ink = Color(0xFF1A2420);
  static const Color muted = Color(0xFF5C6B64);

  static const Color night = Color(0xFF121916);
  static const Color nightSurface = Color(0xFF1C2622);
  static const Color nightVeil = Color(0xFF27332E);
  static const Color nightInk = Color(0xFFE8F0EC);

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
      GoogleFonts.literata(
        fontSize: size,
        fontWeight: w,
        height: 1.12,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle heading(double size, {Color? color, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.literata(
        fontSize: size,
        fontWeight: w,
        height: 1.25,
        letterSpacing: -0.15,
        color: color,
      );

  static TextStyle body(double size, {Color? color, FontWeight w = FontWeight.w400}) =>
      GoogleFonts.karla(fontSize: size, fontWeight: w, height: 1.45, color: color);

  static TextStyle tag(double size, {Color? color, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.karla(
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
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.light().textTheme)
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
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: clay,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: Color(0x55B85C38), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: clay,
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
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
      primary: const Color(0xFF7AB8A8),
      secondary: sage,
      tertiary: ochre,
      surface: nightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: night,
      dividerColor: const Color(0x337AB8A8),
      splashFactory: InkRipple.splashFactory,
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: nightInk, displayColor: nightInk),
      cardTheme: CardThemeData(
        elevation: 0,
        color: nightSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rL),
          side: const BorderSide(color: Color(0x227AB8A8)),
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
        backgroundColor: Color(0xFF7AB8A8),
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
          borderSide: const BorderSide(color: Color(0xFF7AB8A8), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF7AB8A8),
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7AB8A8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: Color(0x557AB8A8), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rM)),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF7AB8A8),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF7AB8A8)),
    );
  }

  /// Cupping forms a leaf note can take.
  static const List<String> cueTypes = [
    'Aroma',
    'Liquor',
    'Body',
    'Origin',
    'Blend',
    'Steep',
    'Pairing',
    'Story',
    'Note',
    'Garden',
    'Ceremony',
    'Other',
  ];

  /// Steep stages, earliest first.
  static const List<String> recallLevels = ['Dry', 'First', 'Settled', 'Cellared', 'Flat'];

  /// Families a caddy belongs to.
  static const List<String> tracks = [
    'Green',
    'Oolong',
    'Black',
    'Puerh',
    'White',
    'Herbal',
    'Matcha',
    'General',
  ];

  static Color getCategoryColor(String category) {
    const map = {
      'Aroma': clay,
      'Liquor': ochre,
      'Body': inkBlue,
      'Origin': wine,
      'Blend': moss,
      'Steep': sage,
      'Pairing': rust,
      'Story': Color(0xFF5C7A9E),
      'Note': inkBlue,
      'Garden': Color(0xFF5C8A6E),
      'Ceremony': Color(0xFFC46B4A),
      'Other': muted,
    };
    return map[category] ?? muted;
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'dry':
        return inkBlue;
      case 'first':
        return ochre;
      case 'settled':
        return sage;
      case 'cellared':
        return moss;
      case 'flat':
        return wine;
      default:
        return muted;
    }
  }

  static double recallStrength(String condition) {
    switch (condition.toLowerCase()) {
      case 'dry':
        return 0.22;
      case 'first':
        return 0.45;
      case 'settled':
        return 0.72;
      case 'cellared':
        return 1.0;
      case 'flat':
        return 0.10;
      default:
        return 0.3;
    }
  }

  static IconData trackIcon(String track) {
    switch (track) {
      case 'Green':
        return Icons.eco_outlined;
      case 'Oolong':
        return Icons.local_florist_outlined;
      case 'Black':
        return Icons.coffee_outlined;
      case 'Puerh':
        return Icons.inventory_2_outlined;
      case 'White':
        return Icons.cloud_outlined;
      case 'Herbal':
        return Icons.spa_outlined;
      case 'Matcha':
        return Icons.grass_outlined;
      default:
        return Icons.emoji_food_beverage_outlined;
    }
  }
}

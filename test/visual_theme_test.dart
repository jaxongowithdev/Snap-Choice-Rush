import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/utils/visual_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('draft stages', () {
    test('strength rises from shelved to ready', () {
      final shelved = VisualTheme.recallStrength('Shelved');
      final seed = VisualTheme.recallStrength('Seed');
      final rough = VisualTheme.recallStrength('Rough');
      final tuned = VisualTheme.recallStrength('Tuned');
      final ready = VisualTheme.recallStrength('Ready');

      expect(shelved, lessThan(seed));
      expect(seed, lessThan(rough));
      expect(rough, lessThan(tuned));
      expect(tuned, lessThan(ready));
      expect(ready, 1.0);
    });

    test('every stage has its own colour', () {
      final colours = VisualTheme.recallLevels
          .map(VisualTheme.getConditionColor)
          .toSet();
      expect(colours.length, VisualTheme.recallLevels.length);
    });

    test('unknown stage falls back instead of throwing', () {
      expect(VisualTheme.recallStrength('nonsense'), greaterThan(0));
      expect(VisualTheme.getConditionColor('nonsense'), VisualTheme.muted);
    });
  });

  group('forms and crafts', () {
    test('every form maps to a colour', () {
      for (final type in VisualTheme.cueTypes) {
        expect(VisualTheme.getCategoryColor(type), isA<Color>());
      }
    });

    test('every craft maps to an icon', () {
      for (final track in VisualTheme.tracks) {
        expect(VisualTheme.trackIcon(track), isA<IconData>());
      }
    });
  });

  group('themes', () {
    test('AppAppearance maps names to theme modes', () {
      expect(AppAppearance.parse('light'), ThemeMode.light);
      expect(AppAppearance.parse('dark'), ThemeMode.dark);
      expect(AppAppearance.parse('system'), ThemeMode.system);
    });

    test('light and dark both build', () {
      expect(VisualTheme.lightTheme.brightness, Brightness.light);
      expect(VisualTheme.darkTheme.brightness, Brightness.dark);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/utils/visual_theme.dart';

void main() {
  group('recall levels', () {
    test('strength rises from faded to locked', () {
      final faded = VisualTheme.recallStrength('Faded');
      final fresh = VisualTheme.recallStrength('Fresh');
      final shaky = VisualTheme.recallStrength('Shaky');
      final steady = VisualTheme.recallStrength('Steady');
      final locked = VisualTheme.recallStrength('Locked');

      expect(faded, lessThan(fresh));
      expect(fresh, lessThan(shaky));
      expect(shaky, lessThan(steady));
      expect(steady, lessThan(locked));
      expect(locked, 1.0);
    });

    test('every level has its own colour', () {
      final colours = VisualTheme.recallLevels
          .map(VisualTheme.getConditionColor)
          .toSet();
      expect(colours.length, VisualTheme.recallLevels.length);
    });

    test('unknown level falls back instead of throwing', () {
      expect(VisualTheme.recallStrength('nonsense'), greaterThan(0));
      expect(VisualTheme.getConditionColor('nonsense'), VisualTheme.muted);
    });
  });

  group('cue types and tracks', () {
    test('every cue type maps to a colour', () {
      for (final type in VisualTheme.cueTypes) {
        expect(VisualTheme.getCategoryColor(type), isA<Color>());
      }
    });

    test('every track maps to an icon', () {
      for (final track in VisualTheme.tracks) {
        expect(VisualTheme.trackIcon(track), isA<IconData>());
      }
    });
  });

  group('themes', () {
    test('light and dark both build', () {
      expect(VisualTheme.lightTheme.brightness, Brightness.light);
      expect(VisualTheme.darkTheme.brightness, Brightness.dark);
    });
  });
}

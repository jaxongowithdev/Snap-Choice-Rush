import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/engine/local_composer.dart';

void main() {
  test('compose an aroma note from a seed without a network', () {
    final draft = LocalComposer.compose(
      title: 'Longjing, west lake',
      seed: 'Chestnut dry leaf. 80C, 45 seconds, glass.',
      form: 'Aroma',
      tags: 'green, chestnut',
    );
    expect(draft, contains('Longjing'));
    expect(draft.toLowerCase(), contains('chestnut'));
  });

  test('tighten drops filler words', () {
    final out = LocalComposer.rewrite(
      'This is really very actually a cup.',
      'Tighten',
    );
    expect(out.toLowerCase().contains('really'), isFalse);
    expect(out.toLowerCase().contains('very'), isFalse);
    expect(out.toLowerCase().contains('actually'), isFalse);
  });

  test('shorter keeps the first two sentences', () {
    final out = LocalComposer.rewrite('One. Two. Three. Four.', 'Shorter');
    expect(out, contains('One'));
    expect(out, contains('Two'));
    expect(out.contains('Four'), isFalse);
  });

  test('every form returns a non-empty draft', () {
    for (final form in [
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
    ]) {
      final draft = LocalComposer.compose(
        title: 'Test leaf',
        seed: '80C, one minute, glass cup.',
        form: form,
      );
      expect(draft.trim(), isNotEmpty, reason: form);
    }
  });
}

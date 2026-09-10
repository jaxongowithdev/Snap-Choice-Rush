import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/engine/local_composer.dart';

void main() {
  test('compose a caption from a seed without a network', () {
    final draft = LocalComposer.compose(
      title: 'Saturday market opener',
      seed: 'Heirloom tomatoes, still warm. Close at two.',
      form: 'Caption',
      tags: 'warm, shop',
    );
    expect(draft, contains('Saturday market opener'));
    expect(draft.toLowerCase(), contains('tomato'));
  });

  test('tighten drops filler words', () {
    final out = LocalComposer.rewrite(
      'This is really very actually a draft.',
      'Tighten',
    );
    expect(out.toLowerCase().contains('really'), isFalse);
    expect(out.toLowerCase().contains('very'), isFalse);
    expect(out.toLowerCase().contains('actually'), isFalse);
  });

  test('shorter keeps the first two sentences', () {
    final out = LocalComposer.rewrite(
      'One. Two. Three. Four.',
      'Shorter',
    );
    expect(out, contains('One'));
    expect(out, contains('Two'));
    expect(out.contains('Four'), isFalse);
  });

  test('every form returns a non-empty draft', () {
    for (final form in [
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
    ]) {
      final draft = LocalComposer.compose(
        title: 'Test job',
        seed: 'A wooden table and a cold cup.',
        form: form,
      );
      expect(draft.trim(), isNotEmpty, reason: form);
    }
  });
}

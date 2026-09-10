/// On-device writing engine for Quietforge.
///
/// Builds readable drafts from a recipe title, seed notes, form, and tags.
/// No network, no cloud model — slot-fill, phrase banks, and rewrite moves.
class LocalComposer {
  LocalComposer._();

  static const moves = ['Tighten', 'Expand', 'Warmer', 'Formal', 'Shorter'];

  static String compose({
    required String title,
    required String seed,
    required String form,
    String tags = '',
  }) {
    final brief = title.trim().isEmpty ? 'Untitled piece' : title.trim();
    final facts = _cleanSeed(seed);
    final voice = _voiceFrom(tags);
    final audience = _audienceFrom(tags, facts);

    return switch (form) {
      'Caption' => _caption(brief, facts, voice, audience),
      'Hook' => _hook(brief, facts, voice),
      'Outline' => _outline(brief, facts, audience),
      'Scene' => _scene(brief, facts, voice),
      'Letter' => _letter(brief, facts, voice, audience),
      'Lesson' => _lesson(brief, facts, audience),
      'Product' => _product(brief, facts, voice, audience),
      'Poem' => _poem(brief, facts),
      'Brief' => _brief(brief, facts, audience),
      'Journal' => _journal(brief, facts, voice),
      'Script' => _script(brief, facts, voice),
      _ => _paragraph(brief, facts, voice, audience),
    };
  }

  static String rewrite(String draft, String move) {
    final text = draft.trim();
    if (text.isEmpty) return text;
    return switch (move) {
      'Tighten' => _tighten(text),
      'Expand' => _expand(text),
      'Warmer' => _warmer(text),
      'Formal' => _formal(text),
      'Shorter' => _shorter(text),
      _ => text,
    };
  }

  // ---- forms ----------------------------------------------------------

  static String _caption(String brief, String facts, String voice, String audience) {
    final image = facts.isEmpty ? brief.toLowerCase() : _firstClause(facts);
    return '$brief.\n\n'
        '${_cap(image)} — made for $audience, spoken $voice.\n'
        'Save this, send it, or pin it where people already look.';
  }

  static String _hook(String brief, String facts, String voice) {
    final bait = facts.isEmpty ? brief : _firstClause(facts);
    return 'What if $bait was the first line they read?\n\n'
        '$brief — said $voice, without a throat-clear.\n'
        'Open with the fact. Let the pitch wait one sentence.';
  }

  static String _outline(String brief, String facts, String audience) {
    final bits = _splitFacts(facts);
    final b1 = bits.isNotEmpty ? bits[0] : 'why this matters to $audience';
    final b2 = bits.length > 1 ? bits[1] : 'one concrete example';
    final b3 = bits.length > 2 ? bits[2] : 'the ask, in one line';
    return '$brief\n\n'
        '1. Promise — name the change $audience will feel.\n'
        '2. Proof — $b1.\n'
        '3. Picture — $b2.\n'
        '4. Path — $b3.\n'
        '5. Close — one next step, no extra menu.';
  }

  static String _scene(String brief, String facts, String voice) {
    final sensory = facts.isEmpty
        ? 'late light on a wooden table, a cup going cold'
        : _firstClause(facts);
    return '$brief\n\n'
        'The room holds $sensory. Someone leans in, $voice, and the next line '
        'has to earn the silence that follows.\n\n'
        'Do not explain the feeling. Put an object in the hand and let it speak.';
  }

  static String _letter(String brief, String facts, String voice, String audience) {
    final body = facts.isEmpty
        ? 'I wanted to put this in writing while it was still clear.'
        : facts;
    return 'Hello $audience,\n\n'
        '$brief.\n\n'
        '$body\n\n'
        'Said $voice, and meant. If this is useful, reply with one line and I will '
        'take the next step.\n\n'
        'Warmly,\n'
        '—';
  }

  static String _lesson(String brief, String facts, String audience) {
    final activity = facts.isEmpty
        ? 'a five-minute write, then a pair swap'
        : _firstClause(facts);
    return 'Lesson: $brief\n\n'
        'For: $audience\n'
        'Aim: leave able to say the idea in their own words.\n'
        'Do: $activity.\n'
        'Check: each person reads one sentence they would keep.\n'
        'Send-home: one line they will use tomorrow.';
  }

  static String _product(String brief, String facts, String voice, String audience) {
    final proof = facts.isEmpty ? 'it works where you already are' : _firstClause(facts);
    return '$brief\n\n'
        'For $audience who are tired of the long way around.\n'
        'It does this: $proof.\n'
        'Spoken $voice — no jargon tax.\n'
        'Try it once. Keep it if the next hour is lighter.';
  }

  static String _poem(String brief, String facts) {
    final line = facts.isEmpty ? brief.toLowerCase() : _firstClause(facts);
    return '$brief\n'
        '${_cap(line)}, held still\n'
        'long enough to hear the grain.\n'
        'Nothing extra. The rest can wait.';
  }

  static String _brief(String brief, String facts, String audience) {
    final problem = facts.isEmpty ? 'the page is blank and the clock is not' : _firstClause(facts);
    return 'Job: $brief\n'
        'Audience: $audience\n'
        'Problem: $problem.\n'
        'Promise: a draft they can use today, not a mood board.\n'
        'Must include: one fact, one feeling, one next step.\n'
        'Must avoid: hype, filler, a second ask.';
  }

  static String _journal(String brief, String facts, String voice) {
    final now = DateTime.now();
    final stamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final body = facts.isEmpty ? 'What I actually did, not what I meant to do.' : facts;
    return '$stamp — $brief\n\n'
        '$body\n\n'
        'Voice: $voice. Keep the true sentence. Cut the one that performs.';
  }

  static String _script(String brief, String facts, String voice) {
    final visual = facts.isEmpty ? 'hands, a table, one object in frame' : _firstClause(facts);
    return 'TITLE: $brief\n\n'
        'VISUAL: $visual.\n'
        'VO ($voice): We start with what they can see, then say why it matters.\n'
        'BEAT: pause. Let the object do a second of work.\n'
        'VO: One ask. Then out.';
  }

  static String _paragraph(String brief, String facts, String voice, String audience) {
    final body = facts.isEmpty ? 'the work is to make one true sentence' : facts;
    return '$brief\n\n'
        'Written $voice for $audience.\n'
        '$body\n'
        'End on a next step, not a summary.';
  }

  // ---- rewrite moves --------------------------------------------------

  static String _tighten(String text) {
    var out = text;
    const filler = [
      ' really',
      ' very',
      ' just',
      ' actually',
      ' basically',
      ' in order to',
      ' that being said,',
      ' it is important to note that',
    ];
    for (final f in filler) {
      out = out.replaceAll(RegExp(f, caseSensitive: false), '');
    }
    out = out.replaceAll('  ', ' ');
    out = out.replaceAll(' ,', ',');
    return out.trim();
  }

  static String _expand(String text) {
    return '$text\n\n'
        'Add one concrete detail here — a time of day, a texture, a number — '
        'so the line has somewhere to stand.';
  }

  static String _warmer(String text) {
    var out = text;
    out = out.replaceAll(RegExp(r'\busers\b', caseSensitive: false), 'you');
    out = out.replaceAll(RegExp(r'\bcustomers\b', caseSensitive: false), 'you');
    out = out.replaceAll(RegExp(r'\bindividuals\b', caseSensitive: false), 'people');
    if (!out.toLowerCase().contains('you')) {
      out = '$out\n\nThis is for you, not for an abstract crowd.';
    }
    return out;
  }

  static String _formal(String text) {
    var out = text;
    const map = {
      "don't": 'do not',
      "doesn't": 'does not',
      "can't": 'cannot',
      "won't": 'will not',
      "it's": 'it is',
      "that's": 'that is',
      "you're": 'you are',
      "we're": 'we are',
      'gonna': 'going to',
      'wanna': 'want to',
      'okay': 'all right',
      'Hey,': 'Hello,',
    };
    map.forEach((k, v) {
      out = out.replaceAll(RegExp(k, caseSensitive: false), v);
    });
    return out;
  }

  static String _shorter(String text) {
    final parts = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (parts.length <= 2) return text.trim();
    return parts.take(2).join(' ').trim();
  }

  // ---- helpers --------------------------------------------------------

  static String _cleanSeed(String seed) {
    final t = seed.trim();
    if (t.isEmpty) return '';
    final cut = t.split(RegExp(r'\n— SPARK —\n|\n--- SPARK ---\n')).first;
    return cut.trim();
  }

  static String _voiceFrom(String tags) {
    final t = tags.toLowerCase();
    if (t.contains('formal')) return 'formally';
    if (t.contains('playful') || t.contains('fun')) return 'with a light step';
    if (t.contains('calm') || t.contains('quiet')) return 'quietly';
    if (t.contains('bold')) return 'without apology';
    if (t.contains('warm')) return 'warmly';
    return 'plainly';
  }

  static String _audienceFrom(String tags, String facts) {
    final t = tags.toLowerCase();
    if (t.contains('student') || t.contains('class')) return 'students';
    if (t.contains('parent')) return 'parents';
    if (t.contains('shop') || t.contains('buyer')) return 'shoppers';
    if (t.contains('team')) return 'the team';
    if (t.contains('reader')) return 'readers';
    if (facts.toLowerCase().contains('class')) return 'the class';
    return 'the person in front of you';
  }

  static List<String> _splitFacts(String facts) {
    if (facts.isEmpty) return [];
    return facts
        .split(RegExp(r'[.;\n•]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static String _firstClause(String facts) {
    final bits = _splitFacts(facts);
    if (bits.isEmpty) return facts;
    var first = bits.first;
    if (first.length > 140) first = '${first.substring(0, 137)}…';
    return first[0].toLowerCase() + first.substring(1);
  }

  static String _cap(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

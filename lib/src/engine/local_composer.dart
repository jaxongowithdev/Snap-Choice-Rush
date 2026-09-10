/// On-device cupping notes for Kettleleaf. No network.
class LocalComposer {
  LocalComposer._();

  static const moves = ['Tighten', 'Expand', 'Warmer', 'Formal', 'Shorter'];

  static String compose({
    required String title,
    required String seed,
    required String form,
    String tags = '',
  }) {
    final leaf = title.trim().isEmpty ? 'Untitled leaf' : title.trim();
    final facts = _cleanSeed(seed);
    final steep = facts.isEmpty ? 'just-off-boil, three minutes' : facts;
    return switch (form) {
      'Aroma' => '$leaf\n\nDry leaf: $steep.\nWet: steam lifts first, then the cup.',
      'Liquor' => '$leaf\n\nIn the cup: $steep.\nColour holds. Drink while it is still talking.',
      'Body' => '$leaf\n\nMouthfeel from $steep.\nMid-sip weight, clean finish, no chalk.',
      'Origin' => '$leaf\n\nPlace in the cup: $steep.\nName the garden, not the catalogue.',
      'Blend' => '$leaf\n\nParts: $steep.\nOne voice leads; the rest keep time.',
      'Steep' => 'Steep card: $leaf\nLeaf / water / time from $steep.\nRinse once. Stop before bitterness.',
      'Pairing' => '$leaf with food.\n$steep\nKeep the plate quieter than the cup.',
      'Story' => '$leaf\n\n$steep\nA short story for the caddy, not a lecture.',
      'Garden' => '$leaf — garden note.\n$steep\nSeason, altitude, one honest fault.',
      'Ceremony' => 'Service: $leaf\n$steep\nWarm the ware. Pour for the other person first.',
      _ => '$leaf\n\n$steep\nOne fact, one feeling, next steep.',
    };
  }

  static String rewrite(String draft, String move) {
    final text = draft.trim();
    if (text.isEmpty) return text;
    return switch (move) {
      'Tighten' => text.replaceAll(RegExp(r' really| very| just| actually', caseSensitive: false), ''),
      'Expand' => '$text\n\nAdd the water temperature and the second steep.',
      'Warmer' => text.contains('you') ? text : '$text\n\nPour this for someone across the table.',
      'Formal' => text.replaceAll("don't", 'do not').replaceAll("it's", 'it is'),
      'Shorter' => () {
          final parts = text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList();
          return parts.length <= 2 ? text : parts.take(2).join(' ');
        }(),
      _ => text,
    };
  }

  static String _cleanSeed(String seed) {
    final t = seed.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\n— SPARK —\n|\n— CUPPING —\n')).first.trim();
  }
}

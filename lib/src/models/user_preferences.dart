// User preferences/settings model
class UserPreferences {
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'en', 'vi', etc.
  final String capacityUnit; // 'items', 'percentage'
  final String defaultBoxPrefix; // 'BOX', 'A', 'B', etc.
  final bool showOnboarding;

  UserPreferences({
    this.theme = 'system',
    this.language = 'en',
    this.capacityUnit = 'pours',
    this.defaultBoxPrefix = 'RAIL',
    this.showOnboarding = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      'capacityUnit': capacityUnit,
      'defaultBoxPrefix': defaultBoxPrefix,
      'showOnboarding': showOnboarding ? 1 : 0,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      theme: map['theme'] as String? ?? 'system',
      language: map['language'] as String? ?? 'en',
      capacityUnit: map['capacityUnit'] as String? ?? 'pours',
      defaultBoxPrefix: map['defaultBoxPrefix'] as String? ?? 'RAIL',
      showOnboarding: (map['showOnboarding'] as int? ?? 1) == 1,
    );
  }

  UserPreferences copyWith({
    String? theme,
    String? language,
    String? capacityUnit,
    String? defaultBoxPrefix,
    bool? showOnboarding,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      defaultBoxPrefix: defaultBoxPrefix ?? this.defaultBoxPrefix,
      showOnboarding: showOnboarding ?? this.showOnboarding,
    );
  }
}

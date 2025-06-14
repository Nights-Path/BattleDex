/// Represents a Pokémon ability with metadata for both UI and battle logic.
class Ability {
  /// Internal key (e.g., "chlorophyll")
  final String name;

  /// Human-readable name (e.g., "Chlorophyll")
  final String displayName;

  /// Whether this is a hidden ability
  final bool isHidden;

  /// Full description or effect text, if available
  final String? effect;

  /// Short description, usually a single sentence
  final String? shortEffect;

  Ability({
    required this.name,
    required this.displayName,
    this.isHidden = false,
    this.effect,
    this.shortEffect,
  });

  /// Deserialize from JSON, accepting either camelCase or snake_case keys
  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String?
              ?? json['display_name'] as String?
              ?? json['name'] as String? ?? '',
      isHidden: json['isHidden'] as bool?
              ?? json['is_hidden'] as bool? ?? false,
      effect: json['effect'] as String? ?? json['description'] as String?,
      shortEffect: json['shortEffect'] as String?
              ?? json['short_effect'] as String?,
    );
  }

  /// Serialize to JSON (camelCase keys)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'displayName': displayName,
      'isHidden': isHidden,
    };
    if (effect != null) data['effect'] = effect;
    if (shortEffect != null) data['shortEffect'] = shortEffect;
    return data;
  }
}

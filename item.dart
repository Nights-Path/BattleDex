/// Represents a held item with metadata for UI display and battle logic.
class Item {
  /// Internal key (e.g., "choice-scarf")
  final String name;

  /// Display name (e.g., "Choice Scarf")
  final String displayName;

  /// Item category (e.g., "choice", "berry", "ball")
  final String category;

  /// Description of the item's effect
  final String? effect;

  /// Short description for compact UI labels
  final String? shortEffect;

  /// Stat modifications granted when held, e.g., {"speed": 10}
  final Map<String, int> statBoosts;

  /// Fling base power, if flingable
  final int? flingPower;

  /// Effect when used with Fling (e.g., "confuse"), or null
  final String? flingEffect;

  Item({
    required this.name,
    required this.displayName,
    required this.category,
    this.effect,
    this.shortEffect,
    Map<String, int>? statBoosts,
    this.flingPower,
    this.flingEffect,
  }) : statBoosts = statBoosts ?? {};

  /// Deserialize from JSON (supports snake_case and camelCase keys)
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String? ?? json['key'] as String,
      displayName: json['displayName'] as String?
          ?? json['display_name'] as String? ?? json['name'] as String,
      category: json['category'] as String? ?? 'item',
      effect: json['effect'] as String? ?? json['description'] as String?,
      shortEffect: json['shortEffect'] as String?
          ?? json['short_effect'] as String?,
      statBoosts: (json['statBoosts'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int))
          ?? {},
      flingPower: json['flingPower'] as int? ?? json['fling_power'] as int?,
      flingEffect: json['flingEffect'] as String?
          ?? json['fling_effect'] as String?,
    );
  }

  /// Serialize to JSON (camelCase)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'displayName': displayName,
      'category': category,
      'statBoosts': statBoosts,
    };
    if (effect != null) data['effect'] = effect;
    if (shortEffect != null) data['shortEffect'] = shortEffect;
    if (flingPower != null) data['flingPower'] = flingPower;
    if (flingEffect != null) data['flingEffect'] = flingEffect;
    return data;
  }
}

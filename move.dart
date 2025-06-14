/// Represents a Pokémon move with full metadata for calculations and UI display.
class Move {
  /// Unique move name key (e.g., "flamethrower")
  final String name;

  /// Display name (e.g., "Flamethrower")
  final String displayName;

  /// Base power (null for status moves)
  final int? power;

  /// Accuracy percentage (null if always hits)
  final int? accuracy;

  /// Target identifier (e.g., "selected-pokemon", "all-opponents")
  final String target;

  /// Move type (e.g., "Fire", "Water")
  final String type;

  /// Damage class: "physical", "special", or "status"
  final String damageClass;

  /// Chance (%) of secondary effect occurring (null if none)
  final int? effectChance;

  /// Raw effect changes as returned by data source
  final List<Map<String, dynamic>> effectChanges;

  /// Detailed move metadata
  final MoveMeta meta;

  Move({
    required this.name,
    required this.displayName,
    this.power,
    this.accuracy,
    required this.target,
    required this.type,
    required this.damageClass,
    this.effectChance,
    List<Map<String, dynamic>>? effectChanges,
    required this.meta,
  }) : effectChanges = effectChanges ?? [];

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      power: json['power'] as int?,
      accuracy: json['accuracy'] as int?,
      target: json['target'] as String,
      type: json['type'] as String,
      damageClass: json['damageClass'] as String,
      effectChance: json['effectChance'] as int?,
      effectChanges: (json['effectChanges'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
          [],
      meta: MoveMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'displayName': displayName,
        'power': power,
        'accuracy': accuracy,
        'target': target,
        'type': type,
        'damageClass': damageClass,
        'effectChance': effectChance,
        'effectChanges': effectChanges,
        'meta': meta.toJson(),
      };
}

/// Additional metadata for a move, beyond power and accuracy.
class MoveMeta {
  /// Status ailment inflicted (e.g., "burn", "paralysis"), or "none"
  final String ailment;

  /// Category: "damage", "ailment", etc.
  final String category;

  /// Crit rate modifier
  final int critRate;

  /// Drain percentage (healing from damage dealt)
  final int drain;

  /// Flinch chance (%)
  final int flinchChance;

  /// Self-healing amount
  final int healing;

  /// Max hits for multi-hit moves (null if fixed)
  final int? maxHits;

  /// Max turns for continuous moves (null if fixed)
  final int? maxTurns;

  /// Min hits for multi-hit moves (null if fixed)
  final int? minHits;

  /// Min turns for continuous moves (null if fixed)
  final int? minTurns;

  /// Chance (%) of stat chance effect
  final int statChance;

  MoveMeta({
    required this.ailment,
    required this.category,
    required this.critRate,
    required this.drain,
    required this.flinchChance,
    required this.healing,
    this.maxHits,
    this.maxTurns,
    this.minHits,
    this.minTurns,
    required this.statChance,
  });

  factory MoveMeta.fromJson(Map<String, dynamic> json) => MoveMeta(
        ailment: json['ailment'] as String? ?? 'none',
        category: json['category'] as String? ?? 'damage',
        critRate: json['critRate'] as int? ?? 0,
        drain: json['drain'] as int? ?? 0,
        flinchChance: json['flinchChance'] as int? ?? 0,
        healing: json['healing'] as int? ?? 0,
        maxHits: json['maxHits'] as int?,
        maxTurns: json['maxTurns'] as int?,
        minHits: json['minHits'] as int?,
        minTurns: json['minTurns'] as int?,
        statChance: json['statChance'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'ailment': ailment,
        'category': category,
        'critRate': critRate,
        'drain': drain,
        'flinchChance': flinchChance,
        'healing': healing,
        'maxHits': maxHits,
        'maxTurns': maxTurns,
        'minHits': minHits,
        'minTurns': minTurns,
        'statChance': statChance,
      };
}

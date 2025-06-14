import '../services/damage_calculator.dart';
import 'move.dart';
import 'ability.dart';
import 'item.dart';

/// Represents a Pokémon with full data needed for both UI and battle logic.
class Pokemon {
  /// Unique internal identifier (e.g., Pokédex number)
  final int id;

  /// Species slug (e.g., "charizard")
  final String species;

  /// Human-readable name (e.g., "Charizard")
  final String nameDisplay;

  /// One or two typing strings (e.g., ["Fire", "Flying"])
  final List<String> types;

  /// Current level (default 50 for VGC)
  final int level;

  /// Base stats: hp, attack, defense, specialAttack, specialDefense, speed
  final Map<String, int> baseStats;

  /// Individual Values (0–31) per stat
  final Map<String, int> ivs;

  /// Effort Values (0–252, sum ≤508) per stat
  final Map<String, int> evs;

  /// Available moves for damage calculations and selectors
  final List<Move> moves;

  /// Currently selected ability
  final Ability ability;

  /// Currently held item (optional)
  final Item? heldItem;

  /// Status condition (e.g., "Burn", null if none)
  final String? status;

  /// Constructs a Pokémon with defaults for IVs, EVs, and level.
  Pokemon({
    required this.id,
    required this.species,
    required this.nameDisplay,
    required this.types,
    this.level = 50,
    required this.baseStats,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    List<Move>? moves,
    required this.ability,
    this.heldItem,
    this.status,
  })  : ivs = ivs ?? const {
          'hp': 31,
          'attack': 31,
          'defense': 31,
          'specialAttack': 31,
          'specialDefense': 31,
          'speed': 31,
        },
        evs = evs ?? const {
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'specialAttack': 0,
          'specialDefense': 0,
          'speed': 0,
        },
        moves = moves ?? [];

  /// JSON deserialization
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      species: json['species'] as String,
      nameDisplay: json['nameDisplay'] as String,
      types: List<String>.from(json['types'] as List<dynamic>),
      level: json['level'] as int? ?? 50,
      baseStats: Map<String, int>.from(json['baseStats'] as Map),
      ivs: Map<String, int>.from(json['ivs'] as Map<String, dynamic>),
      evs: Map<String, int>.from(json['evs'] as Map<String, dynamic>),
      moves: (json['moves'] as List<dynamic>?)
              ?.map((m) => Move.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      ability: Ability.fromJson(json['ability'] as Map<String, dynamic>),
      heldItem: json['heldItem'] != null
          ? Item.fromJson(json['heldItem'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'species': species,
        'nameDisplay': nameDisplay,
        'types': types,
        'level': level,
        'baseStats': baseStats,
        'ivs': ivs,
        'evs': evs,
        'moves': moves.map((m) => m.toJson()).toList(),
        'ability': ability.toJson(),
        'heldItem': heldItem?.toJson(),
        'status': status,
      };

  /// Computes actual stats at [level] given baseStats, IVs, and EVs.
  Map<String, int> get stats =>
      DamageCalculator.calcStats(baseStats, ivs, evs, level);

  /// Creates a copy with any fields overridden.
  Pokemon copyWith({
    int? id,
    String? species,
    String? nameDisplay,
    List<String>? types,
    int? level,
    Map<String, int>? baseStats,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    List<Move>? moves,
    Ability? ability,
    Item? heldItem,
    String? status,
  }) {
    return Pokemon(
      id: id ?? this.id,
      species: species ?? this.species,
      nameDisplay: nameDisplay ?? this.nameDisplay,
      types: types ?? this.types,
      level: level ?? this.level,
      baseStats: baseStats ?? this.baseStats,
      ivs: ivs ?? this.ivs,
      evs: evs ?? this.evs,
      moves: moves ?? this.moves,
      ability: ability ?? this.ability,
      heldItem: heldItem ?? this.heldItem,
      status: status ?? this.status,
    );
  }
}

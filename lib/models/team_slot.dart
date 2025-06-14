import 'pokemon.dart';
import 'move.dart';

/// Represents a single slot on the user's team, including Pokémon selection and chosen moves.
class TeamSlot {
  /// The selected Pokémon for this slot (null if no selection yet).
  final Pokemon? pokemon;

  /// The chosen moves (up to 4) for this slot.
  final List<Move> selectedMoves;

  TeamSlot({
    this.pokemon,
    List<Move>? selectedMoves,
  }) : selectedMoves = selectedMoves ?? [];

  /// JSON deserialization.
  factory TeamSlot.fromJson(Map<String, dynamic> json) {
    return TeamSlot(
      pokemon: json['pokemon'] != null
          ? Pokemon.fromJson(json['pokemon'] as Map<String, dynamic>)
          : null,
      selectedMoves: (json['selectedMoves'] as List<dynamic>?)
              ?.map((m) => Move.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// JSON serialization.
  Map<String, dynamic> toJson() => {
        'pokemon': pokemon?.toJson(),
        'selectedMoves':
            selectedMoves.map((m) => m.toJson()).toList(),
      };

  /// Returns the base stats of the selected Pokémon (or empty map if none).
  Map<String, int> get baseStats => pokemon?.baseStats ?? {};

  /// Returns the calculated stats at level 50 for the selected Pokémon (or empty map if none).
  Map<String, int> get level50Stats => pokemon?.stats ?? {};

  /// Creates a copy with overridden fields.
  TeamSlot copyWith({
    Pokemon? pokemon,
    List<Move>? selectedMoves,
  }) {
    return TeamSlot(
      pokemon: pokemon ?? this.pokemon,
      selectedMoves: selectedMoves ?? this.selectedMoves,
    );
  }
}

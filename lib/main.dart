import '../models/pokemon.dart';
import '../models/team_slot.dart';
import 'damage_calculator.dart';

/// Result of an EV optimization, including per-Pokémon EV spreads and a cumulative score.
class EvResult {
  /// Map from species to EV spread per stat.
  final Map<String, Map<String, int>> spreads;

  /// Aggregate score for the team.
  final double score;

  EvResult({required this.spreads, required this.score});
}

/// Recommendation for a single Pokémon with its optimization score.
class Recommendation {
  final Pokemon pokemon;
  final double score;

  Recommendation(this.pokemon, this.score);
}

/// Service to optimize EV spreads and generate batch recommendations.
class EvOptimizer {
  /// List of high-usage defender Pokémon from Smogon.
  final List<Pokemon> defenders;

  EvOptimizer(this.defenders);

  /// Optimizes EV spreads for the given team slots against the defenders.
  /// Returns an [EvResult] containing per-Pokémon spreads and a score.
  Future<EvResult> optimizeFor(List<TeamSlot> slots) async {
    final Map<String, Map<String, int>> spreads = {};
    double totalScore = 0;

    for (final slot in slots) {
      final poke = slot.pokemon;
      final moves = slot.selectedMoves;
      if (poke == null || moves.isEmpty) continue;

      // 1) Assess threat profile: count defender moves by damage class
      double physThreat = 0, specThreat = 0;
      for (final def in defenders) {
        for (final mv in def.moves) {
          if (mv.damageClass == 'physical') physThreat++;
          else if (mv.damageClass == 'special') specThreat++;
        }
      }
      final double totalThreat = physThreat + specThreat;
      final double physWeight = totalThreat > 0 ? physThreat / totalThreat : 0.5;
      final double specWeight = totalThreat > 0 ? specThreat / totalThreat : 0.5;
      // TODO: incorporate type effectiveness via Type Chart to weight threats more accurately

      // 2) Determine primary offense: compare base output for attack vs special-attack
      final baseStats = poke.baseStats;
      final defaultAttack = DamageCalculator.calcStats(baseStats, poke.ivs, poke.evs, poke.level)['attack']!;
      final defaultSpAttack = DamageCalculator.calcStats(baseStats, poke.ivs, poke.evs, poke.level)['specialAttack']!;
      final bool useAttack = defaultAttack >= defaultSpAttack;
      // ignore weaker offense stat to limit search space

      // 3) Brute-force search over primary offensive EV and speed (increments of 4)
      Map<String, int> bestSpread = {
        'hp': 0,
        'attack': 0,
        'defense': 0,
        'specialAttack': 0,
        'specialDefense': 0,
        'speed': 0,
      };
      double bestScorePerMon = double.negativeInfinity;

      for (int off = 0; off <= 252; off += 4) {
        for (int spe = 0; spe <= 252; spe += 4) {
          // assign EVs to offense and speed; leftover for defenses
          final int leftover = 508 - off - spe;
          if (leftover < 0) continue;

          // distribute defenses proportional to threat
          final int defEv = (leftover * specWeight).floor().clamp(0, 252);
          final int spDefEv = (leftover * physWeight).floor().clamp(0, 252);
          final int hpEv = leftover - defEv - spDefEv;

          final evSpread = {
            'hp': hpEv,
            'attack': useAttack ? off : 0,
            'defense': defEv,
            'specialAttack': useAttack ? 0 : off,
            'specialDefense': spDefEv,
            'speed': spe,
          };

          // 4) Compute damage-based score for this spread
          double score = 0;
          final attacker = poke.copyWith(evs: evSpread);
          for (final def in defenders) {
            for (final move in moves) {
              // only calculate with moves matching offense stat
              if ((useAttack && move.damageClass == 'physical') ||
                  (!useAttack && move.damageClass == 'special')) {
                score += DamageCalculator.computeDamage(
                  attacker: attacker,
                  defender: def,
                  move: move,
                );
              }
            }
          }

          if (score > bestScorePerMon) {
            bestScorePerMon = score;
            bestSpread = evSpread;
          }
        }
      }

      spreads[poke.species] = bestSpread;
      totalScore += bestScorePerMon;
    }

    return EvResult(spreads: spreads, score: totalScore);
  }

  /// Runs the optimizer individually on each candidate Pokémon and returns
  /// a sorted list of [Recommendation] by descending score.
  Future<List<Recommendation>> batchOptimize(List<Pokemon> candidates) async {
    final List<Recommendation> recs = [];
    for (final p in candidates) {
      final singleSlot = [TeamSlot(pokemon: p)];
      try {
        final result = await optimizeFor(singleSlot);
        recs.add(Recommendation(p, result.score));
      } catch (_) {
        // Skip if optimization fails
      }
    }
    recs.sort((a, b) => b.score.compareTo(a.score));
    return recs;
  }
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/pokemon.dart';
import '../models/move.dart';
import '../models/item.dart';
import '../models/ability.dart';
import 'damage_calculator.dart';

/// Centralized service for loading local assets and Smogon usage data.
class DataService {
  // Singleton instance
  static final DataService instance = DataService._();
  DataService._();

  /// Loads Pokémon list from local JSON asset.
  Future<List<Pokemon>> loadLocalPokemon() async {
    final rawJson = await rootBundle.loadString('assets/data/pokemon_data.json');
    final List<dynamic> parsed = jsonDecode(rawJson);
    return parsed
        .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads moves list from local JSON asset.
  Future<List<Move>> loadLocalMoves() async {
    final rawJson = await rootBundle.loadString('assets/data/moves.json');
    final List<dynamic> parsed = jsonDecode(rawJson);
    return parsed
        .map((e) => Move.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads items list from local JSON asset.
  Future<List<Item>> loadLocalItems() async {
    final rawJson = await rootBundle.loadString('assets/data/items.json');
    final List<dynamic> parsed = jsonDecode(rawJson);
    return parsed
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads regulation-legal species list from a local JSON asset.
  /// Expected format: ["pikachu", "charizard", ...]
  Future<List<String>> loadRegulationList() async {
    final rawJson = await rootBundle.loadString('assets/data/regulation_list.json');
    final List<dynamic> parsed = jsonDecode(rawJson);
    return parsed.map((e) => e.toString()).toList();
  }

  /// Initializes the Smogon usage provider (caching and directory setup).
  Future<SmogonUsageProvider> initUsage() async {
    return await SmogonUsageProvider.init();
  }

  /// Fetches the top defenders from Smogon usage data (>=10% usage).
  Future<List<Pokemon>> getHighUsageDefenders() async {
    final provider = await initUsage();
    return provider.getHighUsageDefenders();
  }
}

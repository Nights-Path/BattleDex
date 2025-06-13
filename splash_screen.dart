// 1. ──────────────────────────────────────────────────────────── Imports
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../screens/RedoV0.5.dart';

// 2. ───────────────────────────────────────────────────── Global Pokémon
List<Pokemon> globalPokemonList = [];
List<Items> globalItemsList = [];

// 3. ─────────────────────────────────────────────────────── SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0; // 0.0 → 1.0

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('Starting initialization...');
      final loadPokemonFuture = _loadPokemonListWithProgress()
          .catchError((e) {
        print("Failed to load Pokémon: $e");
        return <Pokemon>[];
      });

      final loadItemsFuture = _loadItemsListWithProgress()
          .catchError((e) {
        print("Failed to load items: $e");
        return <Items>[];
      });

      final timerFuture = Future.delayed(const Duration(seconds: 3));

      final results = await Future.wait([
        loadPokemonFuture,
        loadItemsFuture,
        timerFuture,
      ]);

      globalPokemonList = results[0] as List<Pokemon>;
      globalItemsList = results[1] as List<Items>;

      print("Initialization complete. Mounted: $mounted");
      if (!mounted) {
        print("Widget is not mounted. Skipping navigation.");
        return;
      }

      print("About to push EditorScreen...");
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            // 1. Compute the number of slots as the smaller length
            final slotCount = min(globalPokemonList.length, globalItemsList.length);

            // 3. Navigate with the safely-sized list
            return TeamBuilderScreen(
              pokemonList: globalPokemonList,
              itemsList:   globalItemsList,
              // if you added a slotCount param:
              // slotCount: slotCount,
            );
                      },

        ));
    } catch (e, stack) {
      print("Exception in _initializeApp: $e");
      print(stack);
    }
  }

  // 4. ─────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    print('SplashScreen build() called, progress: $_progress');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 1080,
                height: 1920,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white24,
              color: const Color(0xFF5A78FF),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 5. ─────────────────────────────────────── Loader with progress
  Future<List<Pokemon>> _loadPokemonListWithProgress() async {
    print('Loading Pokémon list...');
    final jsonString = await rootBundle.loadString('assets/pokemon.json');
    final List<dynamic> data = json.decode(jsonString);
    final total = data.length;

    final List<Pokemon> list = [];
    for (var i = 0; i < total; ++i) {
      try {
        list.add(Pokemon.fromJson(data[i]));
      } catch (e) {
        print("⚠️ Skipping Pokémon at index $i: $e");
        continue;
      }

      if (i % 20 == 0 || i == total - 1) {
        _progress = (i + 1) / total * 0.5;
        if (mounted) setState(() {});
        await Future.delayed(Duration.zero);
      }
    }
    print('✅ Pokémon list loaded: ${list.length}');
    return list;
  }

  Future<List<Items>> _loadItemsListWithProgress() async {
    print('Loading items list...');
    final jsonString = await rootBundle.loadString('assets/items.json');
    final List<dynamic> data = json.decode(jsonString);

    final List<Items> itemsList = [];
    final total = data.length;

    for (var i = 0; i < total; i++) {
      final entry = data[i];

      if (entry is! Map<String, dynamic>) {
        print('Skipping item at index $i: not a valid JSON object');
        continue;
      }

      try {
        final item = Items.fromJson(entry);
        itemsList.add(item);
      } catch (e) {
        print('Skipping item at index $i: $e');
        continue;
      }

      if (i % 20 == 0 || i == total - 1) {
        _progress = 0.5 + (i + 1) / total * 0.5;
        if (mounted) setState(() {});
        await Future.delayed(Duration.zero);
      }
    }

    print('✅ Items list loaded: ${itemsList.length}');
    return itemsList;
  }
}

// 6. ───────────────────────────────────────────────────────────── Models
class Stats {
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int specialDefense;
  final int specialAttack;

  Stats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.specialDefense,
    required this.specialAttack,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      hp: (json['hp'] as num?)?.toInt() ?? 0,
      attack: (json['attack'] as num?)?.toInt() ?? 0,
      defense: (json['defense'] as num?)?.toInt() ?? 0,
      speed: (json['speed'] as num?)?.toInt() ?? 0,
      specialDefense: (json['special-defense'] as num?)?.toInt() ?? 0,
      specialAttack: (json['special-attack'] as num?)?.toInt() ?? 0,
    );
  }
}

class Items {
  final String name;
  final String description;

  Items({required this.name, required this.description});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
    );
  }
}

class MovePool {
  final String name;

  MovePool({required this.name,});

  factory MovePool.fromJson(Map<String, dynamic> json) {
    return MovePool(
      name: json['name'] ?? 'Unknown',
    );
  }
}

class Ability {
  final String name;
  final bool isHidden;
  final String displayName;

  Ability({required this.name, required this.isHidden, required this.displayName});

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name'] ?? 'Unknown',
      isHidden: json['is_hidden'] ?? false,
      displayName: json['display_name'] ?? 'Unknown',
    );
  }
}

class PokemonRole {
  final String category;
  final String subcategory;
  final RoleDetails details;

  PokemonRole({
    required this.category,
    required this.subcategory,
    required this.details,
  });

  factory PokemonRole.fromJson(Map<String, dynamic> json) {
    return PokemonRole(
      category: json['category'] ?? 'Unknown',
      subcategory: json['subcategory'] ?? 'Unknown',
      details: RoleDetails.fromJson(json['details'] ?? {}),
    );
  }
}

class RoleDetails {
  final String attackStyle;

  RoleDetails({required this.attackStyle});

  factory RoleDetails.fromJson(Map<String, dynamic> json) {
    return RoleDetails(
      attackStyle: json['attack_style'] ?? 'Unknown',
    );
  }
}

class Pokemon {
  final int id;
  final String nameApi;
  final String nameDisplay;
  final List<String> types;
  final Map<String, int> baseStats;
  final List<Map<String, dynamic>> abilities;
  final List<String> forms;
  final Map<String, dynamic> pokemonRole;
  final List<String> movePool;

  Pokemon({
    required this.id,
    required this.nameApi,
    required this.nameDisplay,
    required this.types,
    required this.baseStats,
    required this.abilities,
    required this.forms,
    required this.pokemonRole,
    required this.movePool,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final baseStats = <String, int>{};
    if (json['stats'] is Map) {
      json['stats'].forEach((key, value) {
        baseStats[key] = (value is int) ? value : int.tryParse(value.toString()) ?? 0;
      });
    }

    // Extract move_pool specifically for this Pokémon
    List<String> currentPokemonMovePool = [];
    if (json['move_pool'] is List) {
      currentPokemonMovePool = (json['move_pool'] as List)
        .map((moveData) {
          // Assuming moveData is a Map and contains a 'name' field
          if (moveData is Map<String, dynamic> && moveData.containsKey('name')) {
            return moveData['name'].toString();
          }
          return moveData.toString(); // Fallback if structure is different
        }).toList();
    }

    return Pokemon(
      id: json['id'] ?? 0,
      nameApi: json['name_api'] ?? '',
      nameDisplay: json['name_display'] ?? json['name_api'] ?? '', // Fallback to name_api
      types: List<String>.from(json['types'] ?? []),
      baseStats: baseStats,
      abilities: (json['abilities'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .toList() ??
          [],
      forms: List<String>.from(json['forms'] ?? []),
      pokemonRole: json['pokemon_role'] ?? {},
      movePool: currentPokemonMovePool,
    );
  }
}

class PokemonDataLoader {
  static Future<List<Pokemon>> loadPokemonList() async {
    final String jsonString = await rootBundle.loadString('assets/data/pokemon_data.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);

    final List<Pokemon> pokemonList = [];
    for (var entry in jsonResponse) {
      try {
        final pokemon = Pokemon.fromJson(entry);
        pokemonList.add(pokemon);
      } catch (e) {
        print('Error parsing Pokémon: $e');
      }
    }

    return pokemonList;
  }
}

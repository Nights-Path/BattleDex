import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/team_slot.dart';
import '../models/pokemon.dart';
import '../models/move.dart';
import '../models/item.dart';
import '../models/ability.dart';
import '../services/ev_optimizer.dart';
import '../theme/theme.dart';
import '../widgets/radar_chart.dart';

/// Data model for recommendations produced by the optimizer.
class Recommendation {
  final Pokemon pokemon;
  final double score;
  Recommendation(this.pokemon, this.score);
}

/// Main screen for building a VGC Pokémon team with two tabs.
class TeamBuilderScreen extends StatefulWidget {
  final List<Pokemon> pokemonList;
  final List<Move> movesList;
  final List<Item> itemsList;
  final List<String> legalSpecies;
  final List<Pokemon> defenders;

  const TeamBuilderScreen({
    Key? key,
    required this.pokemonList,
    required this.movesList,
    required this.itemsList,
    required this.legalSpecies,
    required this.defenders,
  }) : super(key: key);

  @override
  _TeamBuilderScreenState createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<TeamSlot> slots = List.generate(7, (_) => TeamSlot());
  List<Recommendation> recommendations = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Team Builder', style: primaryTextStyle),
        backgroundColor: cardColor,
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: 'Team Builder', icon: Icon(Icons.build)),
            Tab(text: 'Recommended', icon: Icon(Icons.thumb_up)),
          ],
        ),
        actions: _tabs.index == 0
            ? [
                IconButton(
                  icon: Icon(Icons.folder_open),
                  onPressed: _loadTeam,
                ),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveTeam,
                ),
              ]
            : null,
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildTeamBuilderTab(),
          _buildRecommendedTab(),
        ],
      ),
      floatingActionButton: _tabs.index == 0
          ? FloatingActionButton(
              onPressed: _optimizeEvs,
              backgroundColor: selectedColor,
              child: Icon(Icons.auto_fix_high, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTeamBuilderTab() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: slots.length,
      itemBuilder: (ctx, index) => _buildSlotCard(index),
    );
  }

  Widget _buildSlotCard(int index) {
    final slot = slots[index];
    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: primaryButtonStyle,
                  onPressed: () => _showPokemonSelector(index),
                  child: Text(
                    slot.pokemon?.nameDisplay ?? 'Select Pokémon',
                    style: primaryTextStyle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (slot.pokemon != null)
              RadarChart(
                baseData: slot.baseStats,
                level50Data: slot.level50Stats,
              )
            else
              SizedBox(height: 200),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: primaryButtonStyle,
                    onPressed: () => _showAbilitySelector(index),
                    child: Text(
                      slot.pokemon?.ability.displayName ?? 'Select Ability',
                      style: primaryTextStyle,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: primaryButtonStyle,
                    onPressed: () => _showItemSelector(index),
                    child: Text(
                      slot.pokemon?.heldItem?.displayName ?? 'Select Item',
                      style: primaryTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(4, (moveIdx) {
                final move = moveIdx < slot.selectedMoves.length
                    ? slot.selectedMoves[moveIdx]
                    : null;
                return ElevatedButton(
                  style: primaryButtonStyle,
                  onPressed: () => _showMoveSelector(index, moveIdx),
                  child: Text(
                    move?.displayName ?? 'Move ${moveIdx + 1}',
                    style: primaryTextStyle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPokemonSelector(int slotIdx) async {
    final selection = await showModalBottomSheet<Pokemon>(
      context: context,
      builder: (ctx) => ListView(
        children: widget.pokemonList
            .where((p) => widget.legalSpecies.contains(p.species))
            .map((p) => ListTile(
                  title: Text(p.nameDisplay),
                  onTap: () => Navigator.of(ctx).pop(p),
                ))
            .toList(),
      ),
    );
    if (selection != null) {
      setState(() {
        slots[slotIdx] = slots[slotIdx].copyWith(pokemon: selection);
      });
    }
  }

  Future<void> _showAbilitySelector(int slotIdx) async {
    final current = slots[slotIdx].pokemon;
    if (current == null) return;
    final selection = await showModalBottomSheet<Ability>(
      context: context,
      builder: (ctx) => ListView(
        children: [current.ability]
            .map((a) => ListTile(
                  title: Text(a.displayName),
                  onTap: () => Navigator.of(ctx).pop(a),
                ))
            .toList(),
      ),
    );
    if (selection != null) {
      setState(() {
        slots[slotIdx] = slots[slotIdx]
            .copyWith(pokemon: current.copyWith(ability: selection));
      });
    }
  }

  Future<void> _showItemSelector(int slotIdx) async {
    final current = slots[slotIdx].pokemon;
    if (current == null) return;
    final selection = await showModalBottomSheet<Item>(
      context: context,
      builder: (ctx) =>	ListView(
        children: widget.itemsList
            .map((i) => ListTile(
                  title: Text(i.displayName),
                  onTap: () => Navigator.of(ctx).pop(i),
                ))
            .toList(),
      ),
    );
    if (selection != null) {
      setState(() {
        slots[slotIdx] = slots[slotIdx]
            .copyWith(pokemon: current.copyWith(heldItem: selection));
      });
    }
  }

  Future<void> _showMoveSelector(int slotIdx, int moveIdx) async {
    final selection = await showModalBottomSheet<Move>(
      context: context,
      builder: (ctx) => ListView(
        children: widget.movesList
            .map((m) => ListTile(
                  title: Text(m.displayName),
                  onTap: () => Navigator.of(ctx).pop(m),
                ))
            .toList(),
      ),
    );
    if (selection != null) {
      setState(() {
        final moves = List<Move>.from(slots[slotIdx].selectedMoves);
        if (moveIdx < moves.length) moves[moveIdx] = selection;
        else moves.add(selection);
        slots[slotIdx] = slots[slotIdx].copyWith(selectedMoves: moves);
      });
    }
  }

  void _optimizeEvs() async {
    final optimizer = EvOptimizer(widget.defenders);
    final result = await optimizer.optimizeFor(slots);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('EV Optimization Result'),
        content: Text(result.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(slots.map((s) => s.toJson()).toList());
    await prefs.setString('saved_team', jsonString);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Team saved')));
  }

  Future<void> _loadTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('saved_team');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        slots = decoded.map((e) => TeamSlot.fromJson(e)).toList();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Team loaded')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No saved team found')));
    }
  }

  Widget _buildRecommendedTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: primaryButtonStyle,
            icon: Icon(Icons.auto_fix_high),
            label: Text('Run Recommendations'),
            onPressed: _runBatchOptimization,
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (ctx, i) {
                final rec = recommendations[i];
                return ListTile(
                  title: Text(rec.pokemon.nameDisplay),
                  subtitle: Text('Score: ${rec.score.toStringAsFixed(1)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () => _importRecommendation(rec.pokemon),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runBatchOptimization() async {
    final optimizer = EvOptimizer(widget.defenders);
    final List<Recommendation> results = await optimizer.batchOptimize(
      widget.pokemonList
          .where((p) => widget.legalSpecies.contains(p.species))
          .toList(),
    );
    setState(() => recommendations = results);
  }

  void _importRecommendation(Pokemon p) {
    final idx = slots.indexWhere((s) => s.pokemon == null);
    if (idx == -1) return;
    setState(() {
      slots[idx] = slots[idx].copyWith(pokemon: p);
    });
    if (mounted) _tabs.animateTo(0);
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/splash_screen.dart';

const Color backgroundColor = Color(0xFF0C1E36);
const Color cardColor = Color(0xFF1E2B45);
const Color selectedColor = Color(0xFF5A78FF);
const Color unselectedColor = Color(0xFF9DA9C3);
const Color highlightColor = Color(0xFFBDD8A2);
const Color activeStatColor = Color(0x805FB0C3); // 50% alpha
const Color borderColor = Color(0xFF6D88AE);

// --- TeamSlot Model ---
class TeamSlot {
  final String pokemonApiName;
  final String pokemonDisplayName;
  final String abilityName;
  final String itemName;
  final List<String> moves;
  final Map<String, int> baseStats;
  final Map<String, int> level50Stats;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  final String teraType;

  TeamSlot({
    this.pokemonApiName = '',
    this.pokemonDisplayName = '',
    this.abilityName = '',
    this.itemName = '',
    List<String>? moves,
    Map<String, int>? baseStats,
    Map<String, int>? level50Stats,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    this.teraType = '',
  })  : moves = moves ?? List.filled(4, ''),
        baseStats = baseStats ?? <String, int>{
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'specialAttack': 0,
          'specialDefense': 0,
          'speed': 0,
        },
        level50Stats = level50Stats ?? <String, int>{
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'specialAttack': 0,
          'specialDefense': 0,
          'speed': 0,
        },
        ivs = ivs ?? <String, int>{
          'hp': 31,
          'attack': 31,
          'defense': 31,
          'specialAttack': 31,
          'specialDefense': 31,
          'speed': 31,
        },
        evs = evs ?? <String, int>{
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'specialAttack': 0,
          'specialDefense': 0,
          'speed': 0,
        };

  TeamSlot copyWith({
    String? pokemonApiName,
    String? pokemonDisplayName,
    String? abilityName,
    String? itemName,
    List<String>? moves,
    Map<String, int>? baseStats,
    Map<String, int>? level50Stats,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    String? teraType,
  }) {
    return TeamSlot(
      pokemonApiName: pokemonApiName ?? this.pokemonApiName,
      pokemonDisplayName: pokemonDisplayName ?? this.pokemonDisplayName,
      abilityName: abilityName ?? this.abilityName,
      itemName: itemName ?? this.itemName,
      moves: moves ?? this.moves,
      baseStats: baseStats ?? this.baseStats,
      level50Stats: level50Stats ?? this.level50Stats,
      ivs: ivs ?? this.ivs,
      evs: evs ?? this.evs,
      teraType: teraType ?? this.teraType,
    );
  }

  Map<String, dynamic> toJson() => {
    'pokemonApiName': pokemonApiName,
    'pokemonDisplayName': pokemonDisplayName,
    'abilityName': abilityName,
    'itemName': itemName,
    'moves': moves,
    'baseStats': baseStats,
    'level50Stats': level50Stats,
    'ivs': ivs,
    'evs': evs,
    'teraType': teraType,
  };

  factory TeamSlot.fromJson(Map<String, dynamic> json) => TeamSlot(
    pokemonApiName: json['pokemonApiName'] as String? ?? '',
    pokemonDisplayName: json['pokemonDisplayName'] as String? ?? '',
    abilityName: json['abilityName'] as String? ?? '',
    itemName: json['itemName'] as String? ?? '',
    moves: List<String>.from(json['moves'] as List<dynamic>? ?? []),
    baseStats: Map<String, int>.from(json['baseStats'] as Map<String, dynamic>? ?? {}),
    level50Stats: Map<String, int>.from(json['level50Stats'] as Map<String, dynamic>? ?? {}),
    ivs: Map<String, int>.from(json['ivs'] as Map<String, dynamic>? ?? {}),
    evs: Map<String, int>.from(json['evs'] as Map<String, dynamic>? ?? {}),
    teraType: json['teraType'] as String? ?? '',
  );
}

// --- RadarChart Widget ---
class RadarChart extends StatelessWidget {
  final Map<String, int> baseData;
  final Map<String, int> level50Data;
  final double size;

  const RadarChart({
    Key? key,
    required this.baseData,
    required this.level50Data,
    this.size = 125.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _RadarPainter(baseData, level50Data)),
  );
}

class _RadarPainter extends CustomPainter {
  final Map<String, int> baseData;
  final Map<String, int> level50Data;
  final int maxValue = 310;

  _RadarPainter(this.baseData, this.level50Data);

  @override
  void paint(Canvas canvas, Size size) {
    // --- 0) extract every stat into its own variable ---
    final hpBase   = baseData['hp']               ?? 0;
    final atkBase  = baseData['attack']           ?? 0;
    final defBase  = baseData['defense']          ?? 0;
    final speBase  = baseData['speed']            ?? 0;
    final spDefBase= baseData['specialDefense']   ?? baseData['special-defense'] ?? 0;
    final spAtkBase= baseData['specialAttack']    ?? baseData['special-attack'] ?? 0;

    final hpLvl    = level50Data['hp']            ?? 0;
    final atkLvl   = level50Data['attack']        ?? 0;
    final defLvl   = level50Data['defense']       ?? 0;
    final speLvl   = level50Data['speed']         ?? 0;
    final spDefLvl = level50Data['specialDefense']?? level50Data['special-defense'] ?? 0;
    final spAtkLvl = level50Data['specialAttack'] ?? level50Data['special-attack'] ?? 0;

    // Put them in lists in the exact order you want drawn:
    final baseVals = [hpBase, atkBase, defBase, speBase, spDefBase, spAtkBase];
    final lvlVals  = [hpLvl,   atkLvl,   defLvl,   speLvl,   spDefLvl,   spAtkLvl];

    // --- 1) stat keys & labels (for text only) ---
    final stats = ['hp','attack','defense','speed','specialDefense','specialAttack'];
    final labelMap = {
      'hp':'HP','attack':'Atk','defense':'Def',
      'speed':'Spe','specialDefense':'SpD','specialAttack':'SpA',
    };

    // --- 2) manual angles for exactly those positions ---
    final manualAngles = <String,double>{
      'hp':            -math.pi/2,    // top
      'attack':        -math.pi/6,    // top-right
      'defense':        math.pi/6,    // bottom-right
      'speed':          math.pi/2,    // bottom
      'specialDefense': 5*math.pi/6,  // bottom-left
      'specialAttack': -5*math.pi/6,  // top-left
    };

    // --- 3) paints & style ---
    final gridPaint = Paint()..color=Colors.grey..style=PaintingStyle.stroke;
    final basePaint = Paint()..color=highlightColor.withAlpha(125)..style=PaintingStyle.fill;
    final lvlPaint  = Paint()..color=activeStatColor.withAlpha(77)..style=PaintingStyle.fill;
    final textStyle = TextStyle(color: Colors.white, fontSize: 12);

    final center = Offset(size.width/2, size.height/2);
    final radius = math.min(size.width, size.height)/2;

    // --- 4) concentric circles/grid ---
    for (var layer = 1; layer <= 5; layer++) {
      final r = radius * layer / 5;
      final p = Path();
      for (var i = 0; i < stats.length; i++) {
        final a = manualAngles[stats[i]]!;
        final x = center.dx + r * math.cos(a);
        final y = center.dy + r * math.sin(a);
        i==0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      p.close();
      canvas.drawPath(p, gridPaint);
    }

    // --- 5) spokes & labels ---
    for (var i = 0; i < stats.length; i++) {
      final key = stats[i];
      final a = manualAngles[key]!;
      // spoke
      final x2 = center.dx + radius * math.cos(a);
      final y2 = center.dy + radius * math.sin(a);
      canvas.drawLine(center, Offset(x2, y2), gridPaint);
      // label
      final tp = TextPainter(
        text: TextSpan(text: labelMap[key], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final lx = center.dx + (radius + 12) * math.cos(a) - tp.width/2;
      final ly = center.dy + (radius + 12) * math.sin(a) - tp.height/2;
      tp.paint(canvas, Offset(lx, ly));
    }

    // --- 6) data polygons ---
    final basePath = Path();
    final lvlPath  = Path();
    for (var i = 0; i < stats.length; i++) {
      final a = manualAngles[stats[i]]!;
      final b = baseVals[i] / maxValue;
      final l = lvlVals[i]  / maxValue;
      final bx = center.dx + b * radius * math.cos(a);
      final by = center.dy + b * radius * math.sin(a);
      final lx = center.dx + l * radius * math.cos(a);
      final ly = center.dy + l * radius * math.sin(a);

      if (i==0) {
        basePath.moveTo(bx, by);
        lvlPath.moveTo(lx, ly);
      } else {
        basePath.lineTo(bx, by);
        lvlPath.lineTo(lx, ly);
      }
    }
    basePath.close();
    lvlPath.close();
    canvas.drawPath(basePath, basePaint);
    canvas.drawPath(lvlPath, lvlPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// --- TeamBuilderScreen ---
class TeamBuilderScreen extends StatefulWidget {
  final List<Pokemon> pokemonList;
  final List<Items> itemsList;

  const TeamBuilderScreen({
    Key? key,
    required this.pokemonList,
    required this.itemsList,
  }) : super(key: key);

  @override
  _TeamBuilderScreenState createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  late List<TeamSlot> slots;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_team');
    if (saved != null) {
      final list = jsonDecode(saved) as List<dynamic>;
      setState(() {
        slots = list
            .map((e) => TeamSlot.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } else {
      setState(() {
        slots = List.generate(6, (_) => TeamSlot());
      });
    }
  }

  Future<void> _saveTeam() async {
    String? teamName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Save Team', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter team name',
              hintStyle: TextStyle(color: unselectedColor),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: unselectedColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: selectedColor)),
              onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            ),
          ],
        );
      },
    );

    if (teamName == null || teamName.isEmpty) return; // User cancelled or entered empty name

    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(slots.map((s) => s.toJson()).toList());
    await prefs.setString('team_$teamName', jsonString); // Save with the chosen name
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team "$teamName" saved!')));
  }

  Future<void> _showLoadTeamDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final teamKeys = keys.where((key) => key.startsWith('team_')).toList();

    if (teamKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No saved teams found.')));
      return;
    }

    String? selectedTeamKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Load Team', style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teamKeys.length,
              itemBuilder: (context, index) {
                final teamKey = teamKeys[index];
                final teamName = teamKey.substring('team_'.length);
                return ListTile(
                  title: Text(teamName, style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pop(teamKey),
                  onLongPress: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: cardColor,
                          title: Text('Delete Team?', style: TextStyle(color: Colors.white)),
                          content: Text('Are you sure you want to delete the team "$teamName"? This action cannot be undone.', style: TextStyle(color: unselectedColor)),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel', style: TextStyle(color: unselectedColor)),
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                            ),
                            TextButton(
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      await prefs.remove(teamKey);
                      Navigator.of(context).pop(); // Close the load dialog
                      _showLoadTeamDialog(); // Refresh the list
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team "$teamName" deleted.')));
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedTeamKey != null) {
      final jsonString = prefs.getString(selectedTeamKey);
      if (jsonString != null) {
        final decoded = json.decode(jsonString) as List;
        setState(() {
          slots = decoded.map((e) => TeamSlot.fromJson(e as Map<String, dynamic>)).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team "${selectedTeamKey.substring('team_'.length)}" loaded!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text('Team Builder'),
          backgroundColor: cardColor,
          actions: [
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: _showLoadTeamDialog,
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveTeam,
            ),
          ],
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: slots.length,
            itemBuilder: (ctx, index) {
              final slot = slots[index];
              return Card(
                  color: cardColor,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                          children: [
                            // Pokémon & Tera-Type selector
                            InkWell(
                              onTap: () => showPokemonSelector(context, index),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/pokeball.png',
                                    width: 64,
                                    height: 64,
                                  ),
                                  if (slot.pokemonApiName.isNotEmpty)
                                    Image.network(
                                      slot.spriteUrl,
                                      width: 64,
                                      height: 64,
                                    ),
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: InkWell(
                                      onTap: () =>
                                          _showTeraTypeSelector(context, index),
                                      child: Column(
                                        children: [
                                          // TODO: Add default Tera-Type image file 'tera_type_default.png' to assets/images and pubspec.yaml
                                          Image.asset(
                                            slot.teraType.isEmpty
                                                ? 'assets/icons/tera_type_default.png'
                                                : 'assets/icons/tera_type_${slot
                                                .teraType}.png',
                                            width: 28,
                                            height: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            // Radar chart and stat editor
                            InkWell(
                              onTap: () => showStatEditor(context, index),
                              child: SizedBox(
                                height: 150,
                                child:
                                RadarChart(baseData: slot.baseStats,
                                    level50Data: slot.level50Stats),
                              ),
                            ),

                            SizedBox(height: 12),

                            // Moves row
                            Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: List.generate(4, (i) {
                                  final move = slot.moves[i];
                                  return Expanded(
                                      child: InkWell(
                                          onTap: () =>
                                              showMoveSelector(
                                                  context, index, i),
                                          child: Container(
                                              height: 36,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: move.isEmpty
                                                    ? unselectedColor
                                                    : selectedColor,
                                                borderRadius: BorderRadius
                                                    .circular(4),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                  move.isEmpty ? '+' : move,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  Future<void> _saveTeam() async
                                              {
                                              String? teamName = await showDialog<String>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                              title: Text('Save Team As'),
                                              content: TextField(
                                              autofocus: true,
                                              decoration: InputDecoration(hintText: 'Enter team name'),
                                              onSubmitted: (v) => Navigator.of(ctx).pop(v),
                                              ),
                                              actions: [
                                              TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: Text('Cancel'),
                                              ),
                                              TextButton(
                                              onPressed: () {
                                              final controller = TextEditingController();
                                              Navigator.of(ctx).pop(controller.text);
                                              },
                                              child: Text('Save'),
                                              ),
                                              ],
                                              ),
                                              );
                                              if (teamName != null && teamName.isNotEmpty) {
                                              final prefs = await SharedPreferences.getInstance();
                                              final key = 'team_$teamName';
                                              final jsonStr = jsonEncode(slots.map((s) => s.toJson()).toList());
                                              await prefs.setString(key, jsonStr);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(content: Text('Saved as "$teamName"')));
                                              }
                                              }

                                              Future<void> _showLoadTeamDialog()
                                          async {
                                      final prefs = await SharedPreferences.getInstance();
                                      final keys = prefs.getKeys().where((k) => k.startsWith('team_')).toList();
                                      final picked = await showDialog<String>(
                                      context: context,
                                      builder: (ctx) => SimpleDialog(
                                      title: Text('Load Team'),
                                      children: keys.map((k) {
                                      final name = k.substring(5);
                                      return SimpleDialogOption(
                                      child: Text(name),
                                      onPressed: () => Navigator.of(ctx).pop(k),
                                      onLongPress: () async {
                                      final confirm = await showDialog<bool>(
                                      context: ctx,
                                      builder: (_) => AlertDialog(
                                      title: Text('Delete "$name"?'),
                                      actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('No')),
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Yes')),
                                      ],
                                      ),
                                      );
                                      if (confirm == true) {
                                      await prefs.remove(k);
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text('Deleted "$name"')));
                                      }
                                      },
                                      );
                                      }).toList(),
                                      ),
                                      );
                                      if (picked != null) {
                                      final jsonStr = prefs.getString(picked);
                                      if (jsonStr != null) {
                                      final list = jsonDecode(jsonStr) as List<dynamic>;
                                      setState(() {
                                      slots = list.map((e) => TeamSlot.fromJson(e as Map<String, dynamic>)).toList();
                                      });
                                      }
                                      }
                                      }

                                          // Pokémon selector
                                          Future<void> showPokemonSelector(
                                          BuildContext context, int index) async
                                      {
                                      String filter = '';
                                      final selected = await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: backgroundColor,
                                      builder: (ctx) => StatefulBuilder(
                                      builder: (ctx2, setSB) {
                                      final results = widget.pokemonList
                                          .where((p) =>
                                      p.nameDisplay.toLowerCase().contains(filter.toLowerCase()))
                                          .toList();
                                      return Padding(
                                      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                                      child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                      Padding(
                                      padding: EdgeInsets.all(8),
                                      child: TextField(
                                      decoration: InputDecoration(hintText: 'Filter Pokémon'),
                                      onChanged: (v) => setSB(() => filter = v),
                                      ),
                                      ),
                                      Flexible(
                                      child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: results.length,
                                      itemBuilder: (_, i) {
                                      final p = results[i];
                                      return ListTile(
                                      title: Text(p.nameDisplay),
                                      leading: Image.network(p.spriteUrl),
                                      onTap: () => Navigator.of(ctx).pop(p.nameApi),
                                      );
                                      },
                                      ),
                                      ),
                                      ],
                                      ),
                                      );
                                      },
                                      ),
                                      );
                                      if (selected != null) {
                                      final p = widget.pokemonList.firstWhere((p) => p.nameApi == selected);
                                      setState(() {
                                      slots[index] = slots[index].copyWith(
                                      pokemonApiName: p.nameApi,
                                      pokemonDisplayName: p.nameDisplay,
                                      baseStats: p.baseStats,
                                      level50Stats: p.calcLevel50(p.baseStats, slots[index].ivs, slots[index].evs),
                                      abilityName: '',
                                      itemName: '',
                                      moves: List.filled(4, ''),
                                      teraType: '',
                                      );
                                      });
                                      }
                                      }

                                      // Ability selector
                                      Future<void> showAbilitySelector(
                                      BuildContext context, int index)
                                  async {
                                    final slot = slots[index];
                                    final p = widget.pokemonList.firstWhere((
                                        p) => p.nameApi == slot.pokemonApiName);
                                    final chosen = await showModalBottomSheet<
                                        String>(
                                      context: context,
                                      backgroundColor: backgroundColor,
                                      builder: (ctx) =>
                                          ListView(
                                            shrinkWrap: true,
                                            children: p.abilities.map((ab) {
                                              return ListTile(
                                                title: Text(ab.name +
                                                    (ab.isHidden
                                                        ? ' (Hidden)'
                                                        : '')),
                                                onTap: () =>
                                                    Navigator.of(ctx).pop(
                                                        ab.name),
                                              );
                                            }).toList(),
                                          ),
                                    );
                                    if (chosen != null) {
                                      setState(() {
                                        slots[index] = slots[index].copyWith(
                                            abilityName: chosen);
                                      });
                                    }
                                  }

                                  // Move selector
                                  Future<void> showMoveSelector(
                                      BuildContext context, int index,
                                      int moveSlot) async {
                                    final slot = slots[index];
                                    final p = widget.pokemonList.firstWhere((
                                        p) => p.nameApi == slot.pokemonApiName);
                                    String filter = '';
                                    final chosen = await showModalBottomSheet<
                                        List<String>>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: backgroundColor,
                                      builder: (ctx) =>
                                          StatefulBuilder(
                                            builder: (ctx2, setSB) {
                                              final pool = p.movePool
                                                  .map((
                                                  m) => m['name'] as String)
                                                  .toList();
                                              final results = pool
                                                  .where((m) =>
                                                  m.toLowerCase().contains(
                                                      filter.toLowerCase()))
                                                  .toList();
                                              final current = List<String>.from(
                                                  slot.moves);
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: MediaQuery
                                                        .of(ctx)
                                                        .viewInsets
                                                        .bottom),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min, children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                          hintText: 'Filter Moves'),
                                                      onChanged: (v) =>
                                                          setSB(() =>
                                                          filter = v),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: results.length,
                                                      itemBuilder: (_, i) {
                                                        final m = results[i];
                                                        final selected = current
                                                            .contains(m);
                                                        return ListTile(
                                                          title: Text(m),
                                                          trailing: selected
                                                              ? Icon(
                                                              Icons.check)
                                                              : null,
                                                          onTap: () {
                                                            setSB(() {
                                                              if (selected)
                                                                current.remove(
                                                                    m);
                                                              else if (current
                                                                  .length <
                                                                  4) current
                                                                  .add(m);
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(
                                                            current),
                                                    child: Text('✔️ Confirm'),
                                                  ),
                                                ]),
                                              );
                                            },
                                          ),
                                    );
                                    if (chosen != null) {
                                      final updated = List<String>.from(
                                          slots[index].moves);
                                      updated[moveSlot] =
                                      chosen.length > moveSlot
                                          ? chosen[moveSlot]
                                          : '';
                                      setState(() {
                                        slots[index] = slots[index].copyWith(
                                            moves: updated);
                                      });
                                    }
                                  }

                                  // Stat editor
                                  Future<void> showStatEditor(
                                      BuildContext context, int index) async {
                                    final slot = slots[index];
                                    Map<String, int> ivs = Map.from(slot.ivs);
                                    Map<String, int> evs = Map.from(slot.evs);
                                    final updated = await showModalBottomSheet<
                                        Map<String, Map<String, int>>>(
                                      context: context,
                                      backgroundColor: backgroundColor,
                                      isScrollControlled: true,
                                      builder: (ctx) =>
                                          StatefulBuilder(
                                            builder: (ctx2, setSB) {
                                              int totalEv = evs.values.fold(
                                                  0, (a, b) => a + b);
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: MediaQuery
                                                        .of(ctx)
                                                        .viewInsets
                                                        .bottom),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min, children: [
                                                  ...ivs.keys.map((stat) {
                                                    return ListTile(
                                                      title: Text(
                                                          '$stat (IV ${ivs[stat]})'),
                                                      subtitle: Slider(
                                                        min: 0,
                                                        max: 31,
                                                        divisions: 31,
                                                        value: ivs[stat]!
                                                            .toDouble(),
                                                        onChanged: (v) =>
                                                            setSB(() =>
                                                            ivs[stat] =
                                                                v.toInt()),
                                                      ),
                                                    );
                                                  }),
                                                  ...evs.keys.map((stat) {
                                                    return ListTile(
                                                      title: Text(
                                                          '$stat (EV ${evs[stat]})'),
                                                      subtitle: Slider(
                                                        min: 0,
                                                        max: 252,
                                                        divisions: 252,
                                                        value: evs[stat]!
                                                            .toDouble(),
                                                        onChanged: (v) {
                                                          if (totalEv -
                                                              evs[stat]! +
                                                              v.toInt() <= 508)
                                                            setSB(() =>
                                                            evs[stat] =
                                                                v.toInt());
                                                        },
                                                      ),
                                                      trailing: Text(
                                                          'Total EVs: $totalEv/508'),
                                                    );
                                                  }),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop({
                                                          'ivs': ivs,
                                                          'evs': evs
                                                        }),
                                                    child: Text('✔️ Apply'),
                                                  ),
                                                ]),
                                              );
                                            },
                                          ),
                                    );
                                    if (updated != null) {
                                      setState(() {
                                        slots[index] = slots[index].copyWith(
                                          ivs: updated['ivs'],
                                          evs: updated['evs'],
                                          level50Stats:
                                          widget.pokemonList.firstWhere((p) =>
                                          p.nameApi == slot.pokemonApiName)
                                              .calcLevel50(
                                              slot.baseStats, updated['ivs']!,
                                              updated['evs']!),
                                        );
                                      });
                                    }
                                  }

                                  // Item selector
                                  Future<void> showItemSelector(
                                      BuildContext context, int index) async {
                                    String filter = '';
                                    final chosen = await showModalBottomSheet<
                                        String>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: backgroundColor,
                                      builder: (ctx) =>
                                          StatefulBuilder(
                                            builder: (ctx2, setSB) {
                                              final results = widget.itemsList
                                                  .where((i) =>
                                                  i.name.toLowerCase().contains(
                                                      filter.toLowerCase()))
                                                  .toList();
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: MediaQuery
                                                        .of(ctx)
                                                        .viewInsets
                                                        .bottom),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min, children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                          hintText: 'Filter Items'),
                                                      onChanged: (v) =>
                                                          setSB(() =>
                                                          filter = v),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: results.length,
                                                      itemBuilder: (_, i) {
                                                        final it = results[i];
                                                        return ListTile(
                                                          title: Text(it.name),
                                                          onTap: () =>
                                                              Navigator
                                                                  .of(ctx)
                                                                  .pop(it.name),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ]),
                                              );
                                            },
                                          ),
                                    );
                                    if (chosen != null) {
                                      setState(() {
                                        slots[index] = slots[index].copyWith(
                                            itemName: chosen);
                                      });
                                    }
                                  }))));


                                  Future<void> _showTeraTypeSelector(
                                      BuildContext context, int index) async {
                                    const types = [
                                      'normal',
                                      'fire',
                                      'water',
                                      'grass',
                                      'electric',
                                      'ice',
                                      'fighting',
                                      'poison',
                                      'ground',
                                      'flying',
                                      'psychic',
                                      'bug',
                                      'rock',
                                      'ghost',
                                      'dark',
                                      'dragon',
                                      'steel',
                                      'fairy',
                                    ];
                                    final chosen = await showModalBottomSheet<
                                        String>(
                                      context: context,
                                      backgroundColor: backgroundColor,
                                      isScrollControlled: true,
                                      builder: (ctx) =>
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery
                                                    .of(ctx)
                                                    .viewInsets
                                                    .bottom),
                                            child: GridView.count(
                                              crossAxisCount: 4,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(12),
                                              children: types.map((t) {
                                                return GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(ctx).pop(t),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      Image.asset(
                                                        'assets/icons/tera_type_$t.png',
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(t, style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white)),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                    );
                                    if (chosen != null) {
                                      setState(() {
                                        slots[index] = slots[index].copyWith(
                                            teraType: chosen);
                                      });
                                    }
                                  }))
                                  )
                                  );
                                }))
                          ])));
            }));
  }}

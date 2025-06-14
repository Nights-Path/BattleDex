import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/pokemon.dart';
import '../models/move.dart';
import '../models/item.dart';
import 'team_builder.dart';

/// Splash screen that preloads all app data before navigating to the main UI.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Loads all required data and then navigates to TeamBuilderScreen.
  Future<void> _initializeApp() async {
    final ds = DataService.instance;

    setState(() => _statusText = 'Loading Pokémon list...');
    final List<Pokemon> pokemonList = await ds.loadLocalPokemon();

    setState(() => _statusText = 'Loading moves list...');
    final List<Move> movesList = await ds.loadLocalMoves();

    setState(() => _statusText = 'Loading items list...');
    final List<Item> itemsList = await ds.loadLocalItems();

    setState(() => _statusText = 'Loading regulation list...');
    final List<String> legalSpecies = await ds.loadRegulationList();

    setState(() => _statusText = 'Initializing usage data...');
    await ds.initUsage();

    setState(() => _statusText = 'Fetching high-usage defenders...');
    final List<Pokemon> defenders = await ds.getHighUsageDefenders();

    // Navigate to the main team builder screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TeamBuilderScreen(
          pokemonList: pokemonList,
          movesList: movesList,
          itemsList: itemsList,
          legalSpecies: legalSpecies,
          defenders: defenders,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(_statusText),
          ],
        ),
      ),
    );
  }
}

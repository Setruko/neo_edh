import 'package:flutter/material.dart';

void main() {
  runApp(const NeoEdh());
}

class NeoEdh extends StatelessWidget {
  const NeoEdh({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PlayerSetupScreen(),
    );
  }
}

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<TextEditingController> _playerControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _commanderControllers =
      List.generate(4, (_) => TextEditingController());

  void _startGame() {
    final players = List.generate(4, (index) {
      return {
        'playerName': _playerControllers[index].text.trim(),
        'commanderName': _commanderControllers[index].text.trim(),
        'life': 40,
      };
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(players: players),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _playerControllers) {
      controller.dispose();
    }
    for (final controller in _commanderControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commander Setup')),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Player ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _playerControllers[index],
                  decoration: const InputDecoration(labelText: 'Player Name'),
                ),
                TextField(
                  controller: _commanderControllers[index],
                  decoration: const InputDecoration(labelText: 'Commander Name'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startGame,
        label: const Text('Start Game'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final List<Map<String, dynamic>> players;

  const GameScreen({super.key, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Map<String, dynamic>> _players;
  int _currentTurn = 0;
  DateTime? _turnStartTime;
  final List<Duration> _turnDurations = [];
  List<List<Duration>> _playerTurnDurations = []; // Each player's list of turn durations

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.players);
    _playerTurnDurations = List.generate(_players.length, (_) => []);
    _startTurnTimer();
  }

  void _startTurnTimer() {
    _turnStartTime = DateTime.now();
  }

  void _endTurn() {
    if (_turnStartTime != null) {
      final duration = DateTime.now().difference(_turnStartTime!);
      _playerTurnDurations[_currentTurn].add(duration);
    }

    setState(() {
      _currentTurn = (_currentTurn + 1) % _players.length;
    });

    _startTurnTimer();
  }

  void _changeLife(int index, int amount) {
    setState(() {
      _players[index]['life'] += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game in Progress"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Turn: ${_currentTurn + 1}')),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${player['playerName']} (${player['commanderName']})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Life: ${player['life']}', style: const TextStyle(fontSize: 20)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _changeLife(index, -1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _changeLife(index, 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Turn times:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ..._playerTurnDurations[index].asMap().entries.map((entry) {
                    final round = entry.key + 1;
                    final duration = entry.value;
                    final formatted = duration.toString().split('.').first;
                    return Text('Round $round: $formatted');
                  }),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endTurn,
        label: const Text('End Turn'),
        icon: const Icon(Icons.skip_next),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'src/game_engine.dart';

void main() {
  runApp(const InfiniteLogicPrisonApp());
}

class InfiniteLogicPrisonApp extends StatelessWidget {
  const InfiniteLogicPrisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Logic Prison',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C4DFF),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class MyApp extends InfiniteLogicPrisonApp {
  const MyApp({super.key});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final InfiniteLogicEngine _engine = InfiniteLogicEngine();
  final TextEditingController _searchController = TextEditingController();
  String _status = 'Solve with logic only. No luck mechanics.';

  @override
  Widget build(BuildContext context) {
    final room = _engine.currentRoom;
    final clues = _engine.searchNotebook(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Logic Prison'),
        actions: [
          Center(child: Text('IQ: ${_engine.iqStyleScore}')),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Difficulty: ${_engine.difficulty}  •  Attempts: ${_engine.attempts}'),
            const SizedBox(height: 8),
            Text(
              room.prompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < room.options.length; i++)
                  ElevatedButton(
                    onPressed: () {
                      final result = _engine.submitAnswer(i);
                      setState(() {
                        _status = result.correct
                            ? 'Correct. Clue added to notebook timeline.'
                            : 'Incorrect. Re-evaluate trusted clues.';
                      });
                    },
                    child: Text(room.options[i]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_status),
            if (_engine.endgameUnlocked)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('ENDGAME UNLOCKED: synthesize full-history clues.'),
              ),
            const Divider(height: 28),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search notebook clues',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: clues.length,
                itemBuilder: (context, index) {
                  final clue = clues[index];
                  return ListTile(
                    dense: true,
                    title: Text(clue.text),
                    subtitle: Text('Room ${clue.level} • ${clue.trustworthy ? 'Likely true' : 'Potential trap'}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

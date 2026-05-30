import 'package:flutter/material.dart';
import 'dart:async';

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
  static const int _questionTimeLimit = 15;

  final InfiniteLogicEngine _engine = InfiniteLogicEngine();
  final TextEditingController _searchController = TextEditingController();
  Timer? _questionTimer;
  int _remainingSeconds = _questionTimeLimit;
  int _questionStartedAt = DateTime.now().millisecondsSinceEpoch;
  bool _isSubmitting = false;
  String _status = 'Solve with logic only. No luck mechanics.';

  @override
  void initState() {
    super.initState();
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionStartedAt = DateTime.now().millisecondsSinceEpoch;
    _remainingSeconds = _questionTimeLimit;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleAnswer(-1, timedOut: true);
        return;
      }
    });
    setState(() {});
  }

  Future<void> _showSuccessPopup(SubmissionResult result, int answerDuration) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Brilliant!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You solved it like a genius detective.'),
              const SizedBox(height: 8),
              Text('IQ Score: ${result.iqScore}'),
              Text('Answer Time: ${answerDuration}s'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Next Puzzle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAnswer(int selectedIndex, {bool timedOut = false}) async {
    if (_isSubmitting) {
      return;
    }
    _isSubmitting = true;
    _questionTimer?.cancel();

    final answerDuration = ((DateTime.now().millisecondsSinceEpoch - _questionStartedAt) / 1000).floor();
    final result = _engine.submitAnswer(selectedIndex);

    setState(() {
      _status = timedOut
          ? 'Time up! Moved to the next puzzle automatically.'
          : result.correct
              ? 'Correct. Clue added to notebook timeline.'
              : 'Incorrect. Re-evaluate trusted clues.';
    });

    if (result.correct && !timedOut && mounted) {
      await _showSuccessPopup(result, answerDuration);
    }

    if (!mounted) {
      return;
    }
    _isSubmitting = false;
    _startQuestionTimer();
  }

  @override
  Widget build(BuildContext context) {
    final room = _engine.currentRoom;
    final clues = _engine.searchNotebook(_searchController.text);
    final timerProgress = _remainingSeconds / _questionTimeLimit;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Infinite Logic Prison'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Text(
              'IQ: ${_engine.iqStyleScore}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06122E), Color(0xFF14082B), Color(0xFF1B0D1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Difficulty: ${_engine.difficulty}  •  Attempts: ${_engine.attempts}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Time Left: ${_remainingSeconds}s'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: timerProgress.clamp(0, 1),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  room.prompt,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < room.options.length; i++)
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleAnswer(i),
                        icon: const Icon(Icons.vpn_key_outlined, size: 18),
                        label: Text(room.options[i]),
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
                        tileColor: Colors.white.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        title: Text(clue.text),
                        subtitle: Text(
                          'Room ${clue.level} • ${clue.trustworthy ? 'Likely true' : 'Potential trap'}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

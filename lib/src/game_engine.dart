enum PuzzleCategory {
  advancedLogicDeduction,
  mathematicalReasoning,
  patternRecognition,
  cryptography,
  memoryChallenges,
  symbolDecoding,
  strategicDecisionTrees,
  hiddenRuleDiscovery,
}

class ClueEntry {
  const ClueEntry({
    required this.text,
    required this.trustworthy,
    required this.level,
  });

  final String text;
  final bool trustworthy;
  final int level;
}

class PuzzleRoom {
  const PuzzleRoom({
    required this.id,
    required this.level,
    required this.category,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.generatedFrom,
    required this.clue,
  });

  final String id;
  final int level;
  final PuzzleCategory category;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String generatedFrom;
  final ClueEntry clue;
}

class SubmissionResult {
  const SubmissionResult({
    required this.correct,
    required this.room,
    required this.iqScore,
    required this.difficulty,
  });

  final bool correct;
  final PuzzleRoom room;
  final int iqScore;
  final int difficulty;
}

class InfiniteLogicEngine {
  InfiniteLogicEngine({
    List<String>? actionHistory,
    List<ClueEntry>? clueTimeline,
    int solved = 0,
    int mistakes = 0,
    int difficulty = 1,
  })  : _actionHistory = List<String>.from(actionHistory ?? const []),
        _clueTimeline = List<ClueEntry>.from(clueTimeline ?? const []),
        _solved = solved,
        _mistakes = mistakes,
        _difficulty = difficulty;

  final List<String> _actionHistory;
  final List<ClueEntry> _clueTimeline;

  int _solved;
  int _mistakes;
  int _difficulty;

  int get solved => _solved;
  int get mistakes => _mistakes;
  int get difficulty => _difficulty;
  int get attempts => _solved + _mistakes;
  int get iqStyleScore => (_solved * 19) - (_mistakes * 7) + (_difficulty * 5);
  bool get endgameUnlocked => attempts >= 120 && _clueTimeline.length >= 45;
  double get completionRarityPercent =>
      ((100 / (1 + attempts / 14)).clamp(0.1, 100)).toDouble();

  List<String> get actionHistory => List.unmodifiable(_actionHistory);
  List<ClueEntry> get clueTimeline => List.unmodifiable(_clueTimeline);

  PuzzleRoom get currentRoom => _generateRoom(attempts + 1);

  List<ClueEntry> searchNotebook(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return clueTimeline;
    }
    return _clueTimeline.where((c) => c.text.toLowerCase().contains(q)).toList();
  }

  SubmissionResult submitAnswer(int selectedIndex) {
    final room = currentRoom;
    final correct = selectedIndex == room.correctIndex;

    if (correct) {
      _solved += 1;
      _clueTimeline.add(room.clue);
    } else {
      _mistakes += 1;
    }

    _actionHistory.add('L${room.level}:$selectedIndex:${correct ? 'T' : 'F'}');
    _recalculateDifficulty();

    return SubmissionResult(
      correct: correct,
      room: room,
      iqScore: iqStyleScore,
      difficulty: _difficulty,
    );
  }

  PuzzleRoom _generateRoom(int level) {
    final signature = '$level|$_difficulty|${_actionHistory.join(';')}';
    final hash = _stableHash(signature);
    final category = PuzzleCategory.values[hash % PuzzleCategory.values.length];

    final a = 2 + (hash % 9);
    final b = 3 + ((hash ~/ 11) % 11);
    final shift = 1 + ((hash ~/ 29) % 6);

    final correctValue = (a * b) + shift + level;
    final wrongA = correctValue + (level % 3) + 1;
    final wrongB = correctValue - ((level % 4) + 1);
    final wrongC = correctValue + ((hash % 5) + 2);
    final options = [wrongA, wrongB, correctValue, wrongC].map((v) => '$v').toList();
    final correctIndex = 2;

    final clueTrusted = ((hash ~/ 7) + level + _difficulty) % 4 != 0;
    final clue = ClueEntry(
      text: 'Level $level marker ${(hash % 97).toRadixString(16)} -> shift:$shift',
      trustworthy: clueTrusted,
      level: level,
    );

    return PuzzleRoom(
      id: '${level.toString()}-${hash.toRadixString(16)}',
      level: level,
      category: category,
      prompt:
          'Room $level [$category]\nCompute ((A×B)+S+L). A=$a, B=$b, S=$shift, L=$level.\nUse your notebook: trust may be deceptive.',
      options: options,
      correctIndex: correctIndex,
      generatedFrom: signature,
      clue: clue,
    );
  }

  void _recalculateDifficulty() {
    final accuracy = attempts == 0 ? 1.0 : _solved / attempts;
    final dynamicOffset = (attempts / 8).floor();
    final performanceOffset = (accuracy * 6).floor();
    _difficulty = (1 + dynamicOffset + performanceOffset).clamp(1, 99) as int;
  }

  static int _stableHash(String input) {
    var hash = 0x811C9DC5;
    for (final rune in input.runes) {
      hash ^= rune;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}

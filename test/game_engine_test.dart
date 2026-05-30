import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_logic_prison/src/game_engine.dart';

void main() {
  test('room generation is deterministic for same state', () {
    final engineA = InfiniteLogicEngine();
    final engineB = InfiniteLogicEngine();

    expect(engineA.currentRoom.id, engineB.currentRoom.id);
    expect(engineA.currentRoom.correctIndex, engineB.currentRoom.correctIndex);
  });

  test('player decisions alter future room generation', () {
    final baseline = InfiniteLogicEngine();
    final evolving = InfiniteLogicEngine();

    final first = evolving.currentRoom;
    evolving.submitAnswer(first.correctIndex);

    expect(evolving.currentRoom.id, isNot(equals(baseline.currentRoom.id)));
  });

  test('rooms do not repeat in first 40 attempts', () {
    final engine = InfiniteLogicEngine();
    final seen = <String>{};

    for (var i = 0; i < 40; i++) {
      final room = engine.currentRoom;
      expect(seen.add(room.id), isTrue, reason: 'Repeated room id at attempt ${i + 1}');
      engine.submitAnswer(room.correctIndex);
    }
  });

  test('notebook search returns relevant clues', () {
    final engine = InfiniteLogicEngine();

    for (var i = 0; i < 6; i++) {
      final room = engine.currentRoom;
      engine.submitAnswer(room.correctIndex);
    }

    final queryToken = engine.clueTimeline.first.text.split(' ').last;
    final results = engine.searchNotebook(queryToken);

    expect(results, isNotEmpty);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_logic_prison/main.dart';

void main() {
  testWidgets('Game screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Infinite Logic Prison'), findsOneWidget);
    expect(find.text('Solve with logic only. No luck mechanics.'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search notebook clues'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
  });
}

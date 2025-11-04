import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/ui/game_over_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GameOverScreen shows Watch Bonus button', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(50);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    expect(find.text('Watch Bonus (Local)'), findsOneWidget);
  });

  testWidgets('GameOverScreen Watch Bonus opens dialog', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(50);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Watch Bonus (Local)'));
    await tester.pump();

    expect(find.text('Bonus Reward'), findsOneWidget);
    expect(find.text('Local placeholder ad... (no network)'), findsOneWidget);
  });

  testWidgets('GameOverScreen Watch Bonus grants bonus on next start', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(50);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Watch Bonus (Local)'));
    await tester.pump();
    
    // Wait for dialog to close
    await tester.pump(const Duration(seconds: 4));

    provider.startGame();
    expect(provider.score, 100); // 50 + 100 bonus
  });

  testWidgets('GameOverScreen shows different scores correctly', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(75);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    expect(find.text('Score: 75'), findsOneWidget);
    expect(find.text('High Score: 75'), findsOneWidget);
  });
}


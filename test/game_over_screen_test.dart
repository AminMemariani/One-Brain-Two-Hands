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

  testWidgets('GameOverScreen displays score and high score', (tester) async {
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

    expect(find.text('Game Over!'), findsOneWidget);
    expect(find.text('Score: 50'), findsOneWidget);
    expect(find.text('High Score: 50'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
  });

  testWidgets('GameOverScreen Play Again button starts new game', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(30);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Play Again'));
    await tester.pump();

    expect(provider.isPlaying, isTrue);
    expect(provider.score, 0);
  });

  testWidgets('GameOverScreen shows achievement when unlocked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    // Wait for provider to load
    await tester.pump();
    
    provider.startGame();
    provider.incrementElapsed(30.0); // Unlock achievement
    await tester.pump(); // Wait for async save
    provider.incrementScore(10);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Achievement unlocked: Survive 30 seconds'), findsOneWidget);
  });

  testWidgets('GameOverScreen does not show achievement when not unlocked', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(10);
    provider.endGame();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: GameOverScreen(),
        ),
      ),
    );

    expect(find.text('Achievement unlocked: Survive 30 seconds'), findsNothing);
  });
}


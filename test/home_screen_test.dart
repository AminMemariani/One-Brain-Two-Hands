import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/ui/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen shows title and high score when not playing', (tester) async {
    final provider = GameProvider();
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('One Brain Two Hands'), findsOneWidget);
    expect(find.text('Best: 0'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('HomeScreen shows high score correctly', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(100);
    provider.endGame();
    
    // After ending game, isGameOver is true, so GameOverScreen is shown
    // But high score should still be accessible
    expect(provider.highScore, 100);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // When game is over, GameOverScreen shows high score
    expect(find.text('High Score: 100'), findsOneWidget);
  });

  testWidgets('HomeScreen Play button starts game', (tester) async {
    final provider = GameProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pump(); // Don't settle - game scene loading may take time
    
    // Give time for game to initialize
    await tester.pump(const Duration(milliseconds: 100));

    expect(provider.isPlaying, isTrue);
  });

  testWidgets('HomeScreen shows game mode selection', (tester) async {
    final provider = GameProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Endless'), findsOneWidget);
    expect(find.text('Timed'), findsOneWidget);
  });

  testWidgets('HomeScreen shows daily challenge toggle', (tester) async {
    final provider = GameProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Daily Challenge'), findsOneWidget);
  });

  testWidgets('HomeScreen shows game over screen when game ends', (tester) async {
    final provider = GameProvider();
    
    // Start game, score, and end BEFORE rendering widget
    provider.startGame();
    provider.incrementScore(10);
    provider.endGame();
    
    // Verify isGameOver is true
    expect(provider.isGameOver, isTrue);
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // GameOverScreen should be shown when isGameOver is true
    expect(find.text('Game Over!'), findsOneWidget);
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:one_brain_two_hands/main.dart';
import 'package:provider/provider.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:flame/game.dart';
import 'package:one_brain_two_hands/ui/home_screen.dart';
import 'package:one_brain_two_hands/gameplay/game_scene.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: start, pause, resume, and game over flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('One Brain Two Hands'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.byType(GameWidget<GameScene>), findsOneWidget);

    // Access provider to simulate pause
    final home = find.byType(HomeScreen);
    final context = tester.element(home);
    final provider = Provider.of<GameProvider>(context, listen: false);

    provider.pauseGame();
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsNothing);

    provider.endGame();
    await tester.pumpAndSettle();
    expect(find.text('Game Over!'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    expect(find.byType(GameWidget<GameScene>), findsOneWidget);
  });
}



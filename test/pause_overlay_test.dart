import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/ui/pause_overlay.dart';
import 'package:one_brain_two_hands/gameplay/game_scene.dart';

class _TestGameScene extends GameScene {
  bool resumed = false;
  @override
  void resumeGame() {
    resumed = true;
    super.resumeGame();
  }
}

void main() {
  testWidgets('PauseOverlay shows controls and interacts with provider', (tester) async {
    final provider = GameProvider();
    provider.startGame();
    provider.pauseGame();

    final game = _TestGameScene();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: PauseOverlay(),
          ),
        ),
      ),
    );

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('SFX'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Pump overlay with game instance to test resume
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: PauseOverlay(game: game),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(game.resumed, isTrue);

    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(provider.isPlaying, isFalse);
  });
}



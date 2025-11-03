import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/gameplay/game_scene.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('GameScene delegates score updates to provider', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    scene.updateScore(3);
    expect(provider.score, 3);
  });

  test('GameScene gameOver ends game via provider', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    scene.gameOver();
    expect(provider.isPlaying, isFalse);
  });

  test('GameScene pause and resume update provider', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    scene.pauseGame();
    expect(provider.isPaused, isTrue);

    scene.resumeGame();
    expect(provider.isPaused, isFalse);
  });
}



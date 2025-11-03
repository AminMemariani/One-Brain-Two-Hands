import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('startGame initializes playing state', () {
    final provider = GameProvider();

    provider.startGame();

    expect(provider.isPlaying, isTrue);
    expect(provider.isPaused, isFalse);
    expect(provider.score, 0);
    expect(provider.gameSpeed, 1.0);
  });

  test('pause and resume toggle paused state', () {
    final provider = GameProvider();
    provider.startGame();

    provider.pauseGame();
    expect(provider.isPaused, isTrue);

    provider.resumeGame();
    expect(provider.isPaused, isFalse);
  });

  test('incrementScore increases score and updates high score', () async {
    final provider = GameProvider();
    provider.startGame();

    provider.incrementScore(5);

    expect(provider.score, 5);
    expect(provider.highScore, 5);
  });

  test('endGame saves new high score to preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(10);

    provider.endGame();

    expect(provider.isPlaying, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('high_score'), 10);
  });

  test('increaseDifficulty clamps gameSpeed to max 3.0', () {
    final provider = GameProvider();
    provider.startGame();

    for (var i = 0; i < 50; i++) {
      provider.increaseDifficulty();
    }

    expect(provider.gameSpeed, 3.0);
  });

  test('resetScore resets state', () {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(3);

    provider.resetScore();

    expect(provider.score, 0);
    expect(provider.isPlaying, isFalse);
    expect(provider.isPaused, isFalse);
    expect(provider.gameSpeed, 1.0);
  });
}



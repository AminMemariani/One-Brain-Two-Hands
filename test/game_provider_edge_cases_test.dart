import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('GameProvider loads high score from preferences on init', () async {
    SharedPreferences.setMockInitialValues({'high_score': 42});
    final provider = GameProvider();
    
    // Wait for async load
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(provider.highScore, 42);
  });

  test('GameProvider loads ads removed from preferences', () async {
    SharedPreferences.setMockInitialValues({'ads_removed': true});
    final provider = GameProvider();
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(provider.adsRemoved, isTrue);
  });

  test('GameProvider loads achievements from preferences', () async {
    SharedPreferences.setMockInitialValues({
      'achievements': ['survive_30s', 'test_achievement']
    });
    final provider = GameProvider();
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(provider.achievements.contains('survive_30s'), isTrue);
    expect(provider.achievements.contains('test_achievement'), isTrue);
  });

  test('GameProvider startGame applies pending bonus score', () {
    final provider = GameProvider();
    provider.grantNextRunBonus(25);
    
    provider.startGame();
    
    expect(provider.score, 25);
    expect(provider.elapsedSeconds, 0.0);
  });

  test('GameProvider startGame clears pending bonus after applying', () {
    final provider = GameProvider();
    provider.grantNextRunBonus(25);
    provider.startGame();
    
    // Start again - bonus should not apply twice
    provider.endGame();
    provider.startGame();
    
    expect(provider.score, 0);
  });

  test('GameProvider endGame does not save high score if current is lower', () async {
    SharedPreferences.setMockInitialValues({'high_score': 100});
    final provider = GameProvider();
    await Future.delayed(const Duration(milliseconds: 100));
    
    provider.startGame();
    provider.incrementScore(50); // Lower than 100
    provider.endGame();
    
    await Future.delayed(const Duration(milliseconds: 100));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('high_score'), 100); // Should remain 100
  });

  test('GameProvider incrementElapsed does not trigger achievement twice', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.incrementElapsed(30.0);
    expect(provider.achievements.contains('survive_30s'), isTrue);
    
    final initialCount = provider.achievements.length;
    provider.incrementElapsed(0.1); // Should not add again
    expect(provider.achievements.length, initialCount);
  });

  test('GameProvider incrementElapsed triggers achievement at exactly 30 seconds', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.incrementElapsed(29.9);
    expect(provider.achievements.contains('survive_30s'), isFalse);
    
    provider.incrementElapsed(0.1);
    expect(provider.achievements.contains('survive_30s'), isTrue);
  });

  test('GameProvider incrementElapsed ends timed mode at exact limit', () {
    final provider = GameProvider();
    provider.setGameMode(GameMode.timed);
    provider.setTimedModeSeconds(60);
    provider.startGame();
    
    provider.incrementElapsed(59.9);
    expect(provider.isPlaying, isTrue);
    
    provider.incrementElapsed(0.1);
    expect(provider.isPlaying, isFalse);
  });

  test('GameProvider isGameOver returns true when score > 0 and not playing', () {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(10);
    provider.endGame();
    
    expect(provider.isGameOver, isTrue);
  });

  test('GameProvider isGameOver returns false when score is 0', () {
    final provider = GameProvider();
    provider.startGame();
    provider.endGame();
    
    expect(provider.isGameOver, isFalse);
  });

  test('GameProvider isGameOver returns false when still playing', () {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(10);
    
    expect(provider.isGameOver, isFalse);
  });

  test('GameProvider increaseDifficulty does not increase beyond max', () {
    final provider = GameProvider();
    provider.startGame();
    
    // Increase to max
    for (var i = 0; i < 50; i++) {
      provider.increaseDifficulty();
    }
    
    final maxSpeed = provider.gameSpeed;
    provider.increaseDifficulty();
    
    expect(provider.gameSpeed, maxSpeed); // Should not increase further
  });

  test('GameProvider increaseDifficulty does nothing when already at max', () {
    final provider = GameProvider();
    provider.startGame();
    
    // Set to max speed
    provider.adjustGameSpeed(2.0); // 3.0 max
    expect(provider.gameSpeed, 3.0);
    
    provider.increaseDifficulty();
    // Should remain at max
    expect(provider.gameSpeed, 3.0);
  });

  test('GameProvider adjustGameSpeed clamps correctly', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.adjustGameSpeed(-0.5); // Would go below 1.0, so clamped
    expect(provider.gameSpeed, 1.0);
    
    provider.adjustGameSpeed(-1.0); // Should remain at 1.0
    expect(provider.gameSpeed, 1.0);
  });

  test('GameProvider setGameOver false sets isPlaying to false', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.setGameOver(false);
    expect(provider.isPlaying, isFalse);
  });

  test('GameProvider pauseGame only works when playing and not paused', () {
    final provider = GameProvider();
    
    // Not playing
    provider.pauseGame();
    expect(provider.isPaused, isFalse);
    
    provider.startGame();
    provider.pauseGame();
    expect(provider.isPaused, isTrue);
    
    // Already paused
    provider.pauseGame();
    expect(provider.isPaused, isTrue); // Should remain true
  });

  test('GameProvider resumeGame only works when playing and paused', () {
    final provider = GameProvider();
    
    // Not playing
    provider.resumeGame();
    expect(provider.isPaused, isFalse);
    
    provider.startGame();
    // Not paused
    provider.resumeGame();
    expect(provider.isPaused, isFalse);
    
    provider.pauseGame();
    provider.resumeGame();
    expect(provider.isPaused, isFalse);
  });

  test('GameProvider endGame only works when playing', () {
    final provider = GameProvider();
    
    provider.endGame();
    expect(provider.isPlaying, isFalse);
    
    provider.startGame();
    provider.endGame();
    expect(provider.isPlaying, isFalse);
  });

  test('GameProvider startGame resets elapsed seconds', () {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementElapsed(10.0);
    
    provider.endGame();
    provider.startGame();
    
    expect(provider.elapsedSeconds, 0.0);
  });

  test('GameProvider elapsedSeconds getter returns correct value', () {
    final provider = GameProvider();
    provider.startGame();
    
    expect(provider.elapsedSeconds, 0.0);
    
    provider.incrementElapsed(5.5);
    expect(provider.elapsedSeconds, 5.5);
  });
}


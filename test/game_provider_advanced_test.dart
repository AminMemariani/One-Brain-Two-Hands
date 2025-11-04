import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('adjustGameSpeed increases speed within bounds', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.adjustGameSpeed(0.5);
    expect(provider.gameSpeed, 1.5);
    
    provider.adjustGameSpeed(2.0);
    expect(provider.gameSpeed, 3.0); // Clamped to max
  });

  test('adjustGameSpeed clamps to minimum 1.0', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.adjustGameSpeed(-2.0);
    expect(provider.gameSpeed, 1.0); // Clamped to min
  });

  test('incrementElapsed tracks time and triggers achievements', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    provider.startGame();
    
    provider.incrementElapsed(30.0);
    expect(provider.elapsedSeconds, 30.0);
    expect(provider.achievements.contains('survive_30s'), isTrue);
  });

  test('incrementElapsed does not track when not playing', () {
    final provider = GameProvider();
    
    provider.incrementElapsed(10.0);
    expect(provider.elapsedSeconds, 0.0);
  });

  test('incrementElapsed ends timed mode at limit', () {
    final provider = GameProvider();
    provider.setGameMode(GameMode.timed);
    provider.setTimedModeSeconds(60);
    provider.startGame();
    
    provider.incrementElapsed(60.0);
    expect(provider.isPlaying, isFalse);
  });

  test('setDailyChallenge updates state', () {
    final provider = GameProvider();
    
    provider.setDailyChallenge(true);
    expect(provider.isDailyChallenge, isTrue);
    
    provider.setDailyChallenge(false);
    expect(provider.isDailyChallenge, isFalse);
  });

  test('setGameMode updates mode', () {
    final provider = GameProvider();
    
    provider.setGameMode(GameMode.timed);
    expect(provider.gameMode, GameMode.timed);
    
    provider.setGameMode(GameMode.endless);
    expect(provider.gameMode, GameMode.endless);
  });

  test('setTimedModeSeconds clamps to valid range', () {
    final provider = GameProvider();
    
    provider.setTimedModeSeconds(5); // Below minimum
    expect(provider.timedModeSeconds, 10);
    
    provider.setTimedModeSeconds(700); // Above maximum
    expect(provider.timedModeSeconds, 600);
    
    provider.setTimedModeSeconds(60);
    expect(provider.timedModeSeconds, 60);
  });

  test('grantNextRunBonus adds to score on next start', () {
    final provider = GameProvider();
    
    provider.grantNextRunBonus(50);
    provider.startGame();
    
    expect(provider.score, 50);
  });

  test('removeAdsLocally updates state', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    
    // Wait a bit for provider to finish loading
    await Future.delayed(const Duration(milliseconds: 100));
    
    await provider.removeAdsLocally();
    expect(provider.adsRemoved, isTrue);
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('ads_removed'), isTrue);
  });

  test('togglePause toggles pause state', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.togglePause();
    expect(provider.isPaused, isTrue);
    
    provider.togglePause();
    expect(provider.isPaused, isFalse);
  });

  test('setPaused updates pause state', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.setPaused(true);
    expect(provider.isPaused, isTrue);
    
    provider.setPaused(false);
    expect(provider.isPaused, isFalse);
  });

  test('setGameOver ends game', () {
    final provider = GameProvider();
    provider.startGame();
    provider.incrementScore(10);
    
    provider.setGameOver(true);
    expect(provider.isPlaying, isFalse);
    expect(provider.isGameOver, isTrue);
  });

  test('dailySeed returns current day', () {
    final provider = GameProvider();
    expect(provider.dailySeed, DateTime.now().day);
  });

  test('pauseGame does nothing if not playing', () {
    final provider = GameProvider();
    
    provider.pauseGame();
    expect(provider.isPaused, isFalse);
  });

  test('resumeGame does nothing if not paused', () {
    final provider = GameProvider();
    provider.startGame();
    
    provider.resumeGame();
    expect(provider.isPaused, isFalse);
  });

  test('incrementScore does nothing when not playing', () {
    final provider = GameProvider();
    final initialScore = provider.score;
    
    provider.incrementScore(10);
    expect(provider.score, initialScore);
  });
}


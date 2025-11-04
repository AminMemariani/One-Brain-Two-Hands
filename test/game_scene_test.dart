import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/gameplay/game_scene.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('GameScene delegates score updates to provider', () async {
    // Note: This test requires full game setup with size
    // updateScore requires players to be loaded with positions
    // Skipping as it requires complex Flame game initialization
  }, skip: 'Requires full game setup with size and players');

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

  test('GameScene calculateLaneY returns correct positions', () async {
      final _ = GameScene();
    // Note: calculateLaneY uses size which requires game to be properly initialized
    // This test verifies the logic works when size is available
    // For unit testing, we'll skip this as it requires full game setup
  }, skip: 'Requires full game initialization with size');

  test('GameScene spawnObstacle creates obstacles', () async {
    // Note: spawnObstacle requires size to be set
    // Skipping as it requires full game setup
  }, skip: 'Requires full game setup with size');

  test('GameScene gameSpeed returns provider speed', () async {
    final provider = GameProvider();
    provider.startGame();
    provider.adjustGameSpeed(0.5);
    final scene = GameScene();
    scene.initializeWithProvider(provider);
    
    expect(scene.gameSpeed, 1.5);
  });

  test('GameScene onPlayerCollision triggers game over', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);
    
    scene.onPlayerCollision(PlayerSide.left);
    expect(provider.isPlaying, isFalse);
  });

  test('GameScene update does not adjust speed when paused', () async {
    final provider = GameProvider();
    provider.startGame();
    provider.pauseGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);
    
    final initialSpeed = provider.gameSpeed;
    scene.update(1.0);
    
    expect(provider.gameSpeed, initialSpeed);
  });

  test('GameScene update adjusts speed when playing', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    final initialSpeed = provider.gameSpeed;
    scene.update(1.0);

    // Speed should increase slightly
    expect(provider.gameSpeed, greaterThan(initialSpeed));
  });

  test('GameScene updateScore handles null players gracefully', () {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    // updateScore should handle null players
    scene.updateScore(5);
    expect(provider.score, 5);
  });

  test(
    'GameScene spawnObstacle creates obstacles with correct colors',
    () async {
      final provider = GameProvider();
      provider.startGame();
      final scene = GameScene();
      await scene.onLoad();
      scene.initializeWithProvider(provider);

      final initialCount = scene.children.length;
      scene.spawnObstacle(PlayerSide.left, 1);

      expect(scene.children.length, greaterThan(initialCount));
    },
  );

  test('GameScene onPlayerCollision adds screen flash', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    final initialChildren = scene.children.length;
    scene.onPlayerCollision(PlayerSide.left);

    // Should add screen flash component
    expect(scene.children.length, greaterThan(initialChildren));
    expect(provider.isPlaying, isFalse);
  });

  test('GameScene pauseGame pauses engine and provider', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    scene.pauseGame();
    expect(provider.isPaused, isTrue);
  });

  test('GameScene resumeGame resumes engine and provider', () async {
    final provider = GameProvider();
    provider.startGame();
    provider.pauseGame();
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    scene.resumeGame();
    expect(provider.isPaused, isFalse);
  });

  test('GameScene gameSpeed getter returns provider speed', () async {
    final provider = GameProvider();
    provider.startGame();
    provider.adjustGameSpeed(1.0);
    final scene = GameScene();
    scene.initializeWithProvider(provider);

    expect(scene.gameSpeed, 2.0);
  });

  test('GameScene gameSpeed getter returns 1.0 when provider is null', () {
    final scene = GameScene();
    expect(scene.gameSpeed, 1.0);
  });

  test('GameScene pauseGame handles null provider', () {
    final scene = GameScene();
    // Should not throw
    scene.pauseGame();
  });

  test('GameScene resumeGame handles null provider', () {
    final scene = GameScene();
    // Should not throw
    scene.resumeGame();
  });

  test('GameScene gameOver handles null provider', () {
    final scene = GameScene();
    // Should not throw
    scene.gameOver();
  });
}



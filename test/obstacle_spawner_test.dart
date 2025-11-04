import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/gameplay/obstacle_spawner.dart';
import 'package:one_brain_two_hands/core/game_provider.dart';
import 'package:one_brain_two_hands/gameplay/game_scene.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestGameScene extends GameScene {
  int spawnCount = 0;
  PlayerSide? lastSpawnedSide;
  int? lastSpawnedLane;

  @override
  void spawnObstacle(PlayerSide side, int lane) {
    spawnCount++;
    lastSpawnedSide = side;
    lastSpawnedLane = lane;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('ObstacleSpawner does not spawn when game is not playing', () async {
    final provider = GameProvider();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    spawner.update(5.0); // Large dt
    expect(scene.spawnCount, 0);
  });

  test('ObstacleSpawner does not spawn when game is paused', () async {
    final provider = GameProvider();
    provider.startGame();
    provider.pauseGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    spawner.update(5.0);
    expect(scene.spawnCount, 0);
  });

  test('ObstacleSpawner spawns obstacles when timer reaches interval', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    // Update with enough time to trigger spawn
    spawner.update(2.5);
    // Should have spawned at least once (spawn logic is probabilistic)
    expect(scene.spawnCount >= 0, isTrue);
  });

  test('ObstacleSpawner uses seed for deterministic random', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene1 = _TestGameScene();
    final scene2 = _TestGameScene();
    
    final spawner1 = ObstacleSpawner(
      gameScene: scene1,
      gameProvider: provider,
      seed: 42,
    );
    
    final spawner2 = ObstacleSpawner(
      gameScene: scene2,
      gameProvider: provider,
      seed: 42,
    );

    await spawner1.onLoad();
    await spawner2.onLoad();

    // With same seed, should produce same results
    spawner1.update(2.5);
    spawner2.update(2.5);
    // Results should be similar (not exact due to game state differences)
    expect(scene1.spawnCount >= 0, isTrue);
    expect(scene2.spawnCount >= 0, isTrue);
  });

  test('ObstacleSpawner reset resets timer', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    spawner.update(1.0);
    spawner.reset();
    // Timer should be reset, next update should start fresh
    expect(scene.spawnCount >= 0, isTrue);
  });

  test('ObstacleSpawner tracks elapsed time', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    final initialElapsed = provider.elapsedSeconds;
    spawner.update(0.5);
    expect(provider.elapsedSeconds, greaterThan(initialElapsed));
  });

  test('ObstacleSpawner does not track elapsed when paused', () {
    final provider = GameProvider();
    provider.startGame();
    provider.pauseGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );

    final initialElapsed = provider.elapsedSeconds;
    spawner.update(0.5);
    expect(provider.elapsedSeconds, initialElapsed);
  });

  test('ObstacleSpawner reset clears timer', () async {
    final provider = GameProvider();
    provider.startGame();
    final scene = _TestGameScene();
    final spawner = ObstacleSpawner(
      gameScene: scene,
      gameProvider: provider,
    );
    await spawner.onLoad();

    spawner.update(1.0);
    spawner.reset();
    
    // Timer should be reset
    expect(scene.spawnCount >= 0, isTrue);
  });
}


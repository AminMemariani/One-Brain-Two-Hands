import 'dart:math' as math;
import 'package:flame/components.dart';
import 'game_scene.dart';
import '../core/game_provider.dart';
import 'player.dart';

/// Component that handles obstacle spawning using timer-based logic
class ObstacleSpawner extends Component with HasGameRef<GameScene> {
  final GameScene gameScene;
  final GameProvider gameProvider;
  late math.Random _random;
  final int? seed;
  
  double _spawnTimer = 0.0;
  double _baseSpawnInterval = 2.0; // Base interval in seconds
  double _minSpawnInterval = 0.8; // Minimum interval (highest difficulty)
  
  ObstacleSpawner({
    required this.gameScene,
    required this.gameProvider,
    this.seed,
  });
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Only spawn if game is playing and not paused
    if (!gameProvider.isPlaying || gameProvider.isPaused) {
      return;
    }
    // Track elapsed time for achievements
    gameProvider.incrementElapsed(dt);
    
    // Update spawn timer
    _spawnTimer += dt;
    
    // Calculate current spawn interval based on game speed
    double currentInterval = _calculateSpawnInterval();
    
    // Spawn obstacles when timer reaches interval
    if (_spawnTimer >= currentInterval) {
      _spawnRandomObstacles();
      _spawnTimer = 0.0; // Reset timer
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _random = seed != null ? math.Random(seed) : math.Random();
  }
  
  /// Calculate spawn interval based on game speed
  /// gameSpeed increases difficulty by reducing spawn interval
  double _calculateSpawnInterval() {
    // Inverse relationship: higher gameSpeed = lower interval
    // Clamp between base interval and minimum interval
    double interval = _baseSpawnInterval / gameProvider.gameSpeed;
    
    // Add some randomness (±20%)
    double randomness = _random.nextDouble() * 0.4 - 0.2; // -0.2 to 0.2
    interval = interval * (1.0 + randomness);
    
    // Ensure minimum interval to prevent spawning too fast
    return interval.clamp(_minSpawnInterval, _baseSpawnInterval * 1.5);
  }
  
  /// Spawn obstacles randomly in lanes for both players
  void _spawnRandomObstacles() {
    // Randomly decide which lanes to spawn obstacles in
    // Each side can have 0-2 obstacles at a time
    
    // Left side obstacle
    if (_random.nextDouble() > 0.3) { // 70% chance to spawn
      int leftLane = _random.nextInt(GameScene.totalLanes);
      gameScene.spawnObstacle(PlayerSide.left, leftLane);
    }
    
    // Right side obstacle
    if (_random.nextDouble() > 0.3) { // 70% chance to spawn
      int rightLane = _random.nextInt(GameScene.totalLanes);
      gameScene.spawnObstacle(PlayerSide.right, rightLane);
    }
  }
  
  /// Reset spawner (useful when game restarts)
  void reset() {
    _spawnTimer = 0.0;
  }
}


import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'player.dart';
import 'obstacle.dart';
import 'tap_handler.dart';
import 'obstacle_spawner.dart';
import '../core/game_provider.dart';

class GameScene extends FlameGame with HasCollisionDetection {
  late Player leftPlayer;
  late Player rightPlayer;
  GameProvider? gameProvider;
  ObstacleSpawner? _obstacleSpawner;
  
  // Lane configuration
  static const int totalLanes = 3;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize left player (left side of screen)
    leftPlayer = Player(
      side: PlayerSide.left,
      screenWidth: size.x,
      screenHeight: size.y,
      totalLanes: totalLanes,
    );
    add(leftPlayer);
    
    // Initialize right player (right side of screen)
    rightPlayer = Player(
      side: PlayerSide.right,
      screenWidth: size.x,
      screenHeight: size.y,
      totalLanes: totalLanes,
    );
    add(rightPlayer);
    
    // Add tap handler for controlling players
    // Will be re-added after gameProvider is initialized
  }

  void initializeWithProvider(GameProvider provider) {
    gameProvider = provider;
    
    // Add tap handler now that gameProvider is available
    add(TapHandler(
      leftPlayer: leftPlayer,
      rightPlayer: rightPlayer,
      shouldHandleTap: () => gameProvider?.isPlaying == true && gameProvider?.isPaused == false,
    ));
    
    // Initialize obstacle spawner with timer-based spawning
    _obstacleSpawner = ObstacleSpawner(
      gameScene: this,
      gameProvider: provider,
    );
    add(_obstacleSpawner!);
  }
  
  /// Calculate Y position for a lane (for obstacle spawning from top)
  double calculateLaneY(int lane) {
    double laneHeight = (size.y - 60) / (totalLanes - 1);
    return lane * laneHeight + 30;
  }
  
  /// Spawn an obstacle at a specific lane for a player side
  void spawnObstacle(PlayerSide side, int lane) {
    double xPosition = side == PlayerSide.left 
        ? size.x * 0.25 
        : size.x * 0.75;
    
    // Spawn from top (y = 0 or slightly above)
    Vector2 spawnPosition = Vector2(xPosition - 20, -60); // Start above screen
    
    Obstacle obstacle = Obstacle(
      position: spawnPosition,
      size: Vector2(40, 60),
      side: side,
      gameSpeed: gameProvider?.gameSpeed ?? 1.0,
      onPlayerCollision: onPlayerCollision,
    );
    
    add(obstacle);
  }

  void updateScore(int points) {
    if (gameProvider != null) {
      gameProvider!.incrementScore(points);
    }
  }

  void gameOver() {
    if (gameProvider != null) {
      gameProvider!.endGame();
    }
  }

  void pauseGame() {
    pauseEngine();
    if (gameProvider != null) {
      gameProvider!.pauseGame();
    }
  }

  void resumeGame() {
    resumeEngine();
    if (gameProvider != null) {
      gameProvider!.resumeGame();
    }
  }

  /// Get current game speed multiplier
  double get gameSpeed => gameProvider?.gameSpeed ?? 1.0;
  
  /// Handle player collision - called when obstacle detects collision
  void onPlayerCollision(PlayerSide side) {
    gameOver();
  }
}

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'player.dart';
import 'obstacle.dart';
import 'tap_handler.dart';
import 'obstacle_spawner.dart';
import '../core/game_provider.dart';
import '../core/audio_manager.dart';
import 'package:flame/particles.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameScene extends FlameGame with HasCollisionDetection {
  late Player leftPlayer;
  late Player rightPlayer;
  GameProvider? gameProvider;
  ObstacleSpawner? _obstacleSpawner;
  late PlayerSkin _leftSkin;
  late PlayerSkin _rightSkin;
  late Color _leftObstacleColor;
  late Color _rightObstacleColor;
  final math.Random _random = math.Random();
  final double _speedAccelPerSecond = 0.05;
  
  // Lane configuration
  static const int totalLanes = 3;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Random palette per session
    final skins = List<PlayerSkin>.from(PlayerSkin.allSkins);
    skins.shuffle(_random);
    _leftSkin = skins[0];
    _rightSkin = skins.length > 1 ? skins[1] : skins[0];
    _leftObstacleColor = _leftSkin.secondaryColor;
    _rightObstacleColor = _rightSkin.secondaryColor;
    
    // Initialize left player (left side of screen)
    leftPlayer = Player(
      side: PlayerSide.left,
      screenWidth: size.x,
      screenHeight: size.y,
      totalLanes: totalLanes,
      skin: _leftSkin,
    );
    add(leftPlayer);
    
    // Initialize right player (right side of screen)
    rightPlayer = Player(
      side: PlayerSide.right,
      screenWidth: size.x,
      screenHeight: size.y,
      totalLanes: totalLanes,
      skin: _rightSkin,
    );
    add(rightPlayer);
    
    // Add tap handler for controlling players
    // Will be re-added after gameProvider is initialized
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (gameProvider == null || !gameProvider!.isPlaying || gameProvider!.isPaused) {
      return;
    }
    // Smooth acceleration of game speed over time
    gameProvider!.adjustGameSpeed(_speedAccelPerSecond * dt);
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
      color: side == PlayerSide.left ? _leftObstacleColor : _rightObstacleColor,
    );
    
    add(obstacle);
  }

  void updateScore(int points) {
    if (gameProvider != null) {
      gameProvider!.incrementScore(points);
      // Play score SFX
      // ignore: unused_result
      AudioManager().playScore();
      // Particle bursts near both players
      _spawnScoreParticles(leftPlayer.position);
      _spawnScoreParticles(rightPlayer.position);
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
    add(_ScreenFlash(duration: 0.2, color: Colors.white));
    gameOver();
  }
  
  void _spawnScoreParticles(Vector2 at) {
    final particle = Particle.generate(
      count: 12,
      lifespan: 0.4,
      generator: (i) => AcceleratedParticle(
        acceleration: Vector2(0, 400),
        speed: (Vector2.random(_random) - Vector2.all(0.5)) * 200,
        position: at.clone(),
        child: CircleParticle(
          radius: 2,
          paint: Paint()
            ..color = _random.nextBool() ? _leftSkin.accentColor : _rightSkin.accentColor,
        ),
      ),
    );
    add(ParticleSystemComponent(particle: particle));
  }
}

class _ScreenFlash extends Component with HasGameRef {
  final double duration;
  final Color color;
  double _time = 0;
  _ScreenFlash({required this.duration, required this.color});

  @override
  void render(Canvas canvas) {
    final t = (_time / duration).clamp(0.0, 1.0);
    final alpha = (255 * (1.0 - t)).toInt().clamp(0, 255);
    final paint = Paint()..color = color.withAlpha(alpha);
    canvas.drawRect(Offset.zero & gameRef.size.toSize(), paint);
  }

  @override
  void update(double dt) {
    _time += dt;
    if (_time >= duration) {
      removeFromParent();
    }
  }
}

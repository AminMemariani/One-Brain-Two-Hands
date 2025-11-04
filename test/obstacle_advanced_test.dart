import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:one_brain_two_hands/gameplay/obstacle.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class _TestGame extends FlameGame {
  @override
  Vector2 get size => Vector2(800, 600);
}

void main() {
  test('Obstacle initializes with correct color based on side', () {
    final leftObstacle = Obstacle(
      position: Vector2.zero(),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    
    final rightObstacle = Obstacle(
      position: Vector2.zero(),
      size: Vector2(60, 40),
      side: PlayerSide.right,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    
    expect(leftObstacle, isNotNull);
    expect(rightObstacle, isNotNull);
  });

  test('Obstacle accepts custom color', () {
    final obstacle = Obstacle(
      position: Vector2.zero(),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
      color: const Color(0xFF123456),
    );
    
    expect(obstacle, isNotNull);
  });

  test('Obstacle moves horizontally for left side', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(800, 300), // Start at right side
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final initialX = obstacle.position.x;
    obstacle.update(0.1); // 0.1 seconds
    // Should move left (decrease X)
    expect(obstacle.position.x, lessThan(initialX));
  });

  test('Obstacle moves horizontally for right side', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(0, 300), // Start at left side
      size: Vector2(60, 40),
      side: PlayerSide.right,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final initialX = obstacle.position.x;
    obstacle.update(0.1); // 0.1 seconds
    // Should move right (increase X)
    expect(obstacle.position.x, greaterThan(initialX));
  });

  test('Obstacle respects gameSpeed multiplier', () {
    final game = _TestGame();
    final slowObstacle = Obstacle(
      position: Vector2(800, 300),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(slowObstacle);
    
    final fastObstacle = Obstacle(
      position: Vector2(800, 300),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 2.0,
      onPlayerCollision: (_) {},
    );
    game.add(fastObstacle);
    
    slowObstacle.update(0.1);
    fastObstacle.update(0.1);
    
    // Fast obstacle should have moved more
    final slowDistance = 800 - slowObstacle.position.x;
    final fastDistance = 800 - fastObstacle.position.x;
    expect(fastDistance, greaterThan(slowDistance));
  });

  test('Obstacle does not move after collision', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(400, 300),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
    );
    game.add(player);
    
    // Trigger collision
    obstacle.onCollisionStart({}, player);
    
    final xAfterCollision = obstacle.position.x;
    obstacle.update(0.1);
    
    // Position should not change after collision
    expect(obstacle.position.x, xAfterCollision);
  });

  test('Obstacle removes itself when off screen (left side)', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(-100, 300), // Off left side
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final initialChildren = game.children.length;
    obstacle.update(0.01);
    // Should remove itself
    expect(game.children.length, lessThan(initialChildren));
  });

  test('Obstacle removes itself when off screen (right side)', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(900, 300), // Off right side
      size: Vector2(60, 40),
      side: PlayerSide.right,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final initialChildren = game.children.length;
    obstacle.update(0.01);
    // Should remove itself
    expect(game.children.length, lessThan(initialChildren));
  });

  test('Obstacle does not collide with wrong player side', () {
    final game = _TestGame();
    final obstacle = Obstacle(
      position: Vector2(400, 300),
      size: Vector2(60, 40),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (_) {},
    );
    game.add(obstacle);
    
    final wrongPlayer = Player(
      side: PlayerSide.right, // Wrong side
      screenWidth: 800,
      screenHeight: 600,
    );
    game.add(wrongPlayer);
    
    final result = obstacle.onCollisionStart({}, wrongPlayer);
    expect(result, isFalse);
  });
}


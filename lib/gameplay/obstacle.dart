import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import '../core/audio_manager.dart';

class Obstacle extends PositionComponent with HasGameRef, CollisionCallbacks {
  final PlayerSide side;
  final double gameSpeed;
  final double _baseSpeed = 300.0;
  final void Function(PlayerSide) onPlayerCollision;
  bool _hasCollided = false;
  
  // Visual properties
  final Color _obstacleColor;
  final Paint _fillPaint;
  final Paint _borderPaint;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.side,
    required this.gameSpeed,
    required this.onPlayerCollision,
  })  : _obstacleColor = side == PlayerSide.left ? Colors.red : Colors.orange,
        _fillPaint = Paint()..style = PaintingStyle.fill,
        _borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
        super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add simple rectangular collision box
    add(RectangleHitbox());
    
    // Set obstacle color
    _fillPaint.color = _obstacleColor;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_hasCollided) {
      return;
    }
    
    // Move obstacle from top downward toward the player
    double speed = _baseSpeed * gameSpeed;
    position.y += speed * dt;
    
    // Remove if off screen at the bottom
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw a simple rectangle moving from top
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    // Draw filled rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
      _fillPaint,
    );
    
    // Draw border to make it more visible
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4.0)),
      _borderPaint,
    );
    
    // Add a small visual indicator (stripes or pattern)
    _drawPattern(canvas, rect);
  }
  
  void _drawPattern(Canvas canvas, Rect rect) {
    // Draw diagonal stripes for visual interest
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw two diagonal lines
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.bottom),
      patternPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.top),
      patternPaint,
    );
  }

  @override
  bool onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Handle collision with the matching player (check player side)
    if (other is Player && other.side == side && !_hasCollided) {
      _hasCollided = true;
      
      // Play collision sound
      AudioManager().playSound('sounds/crash.mp3').catchError((e) {
        // Fallback: log error if sound file doesn't exist
        // In production, you would have actual sound files in assets
        print('Could not play crash sound: $e');
      });
      
      // Trigger game over callback
      onPlayerCollision(side);
      return true;
    }
    
    return false;
  }
}

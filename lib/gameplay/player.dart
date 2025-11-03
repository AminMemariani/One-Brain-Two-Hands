import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum PlayerSide { left, right }

enum PlayerAnimationState {
  idle,
  move,
  jump,
}

/// Player skin configuration for customization
class PlayerSkin {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String name;

  const PlayerSkin({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.name,
  });

  // Predefined skins
  static const PlayerSkin blue = PlayerSkin(
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF1976D2),
    accentColor: Color(0xFF64B5F6),
    name: 'Blue',
  );

  static const PlayerSkin green = PlayerSkin(
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF388E3C),
    accentColor: Color(0xFF81C784),
    name: 'Green',
  );

  static const PlayerSkin purple = PlayerSkin(
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: Color(0xFF7B1FA2),
    accentColor: Color(0xFFBA68C8),
    name: 'Purple',
  );

  static const PlayerSkin orange = PlayerSkin(
    primaryColor: Color(0xFFFF9800),
    secondaryColor: Color(0xFFF57C00),
    accentColor: Color(0xFFFFB74D),
    name: 'Orange',
  );

  static const List<PlayerSkin> allSkins = [blue, green, purple, orange];
}

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  final PlayerSide side;
  final double laneWidth;
  final int totalLanes;
  final PlayerSkin skin;
  
  int _currentLane = 1; // Middle lane (0-indexed, so lane 1 is middle)
  bool _isSwitchingLanes = false;
  double _targetY = 0;
  final double _switchSpeed = 500.0;
  
  // Animation state
  PlayerAnimationState _animationState = PlayerAnimationState.idle;
  double _animationTime = 0.0;
  double _jumpHeight = 0.0;
  double _idlePulseScale = 1.0;
  
  // Animation timing
  static const double _idlePulseSpeed = 2.0;
  static const double _idlePulseAmount = 0.1;
  static const double _jumpDuration = 0.3;
  static const double _maxJumpHeight = 10.0;
  
  // Base size (will be modified by animations)
  static const double _baseSize = 60.0;
  Vector2 _animatedSize = Vector2(_baseSize, _baseSize);

  Player({
    required this.side,
    required double screenWidth,
    required double screenHeight,
    this.totalLanes = 3,
    PlayerSkin? skin,
  })  : laneWidth = screenHeight / (totalLanes + 1),
        skin = skin ?? (side == PlayerSide.left ? PlayerSkin.blue : PlayerSkin.green),
        super(size: Vector2.all(_baseSize));

  int get currentLane => _currentLane;
  PlayerAnimationState get animationState => _animationState;
  PlayerSkin get playerSkin => skin;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Calculate initial X position based on side
    double xPosition = side == PlayerSide.left 
        ? gameRef.size.x * 0.25 
        : gameRef.size.x * 0.75;
    
    // Calculate initial Y position (middle lane)
    _targetY = _calculateLaneY(_currentLane);
    position = Vector2(xPosition, _targetY);
    
    // Add simple rectangular collision box
    add(RectangleHitbox());
  }
  
  /// Set custom skin (local-only customization)
  void setSkin(PlayerSkin newSkin) {
    // Note: This would typically be handled by a constructor parameter
    // but we can't change it after creation. This is kept for future use.
  }

  double _calculateLaneY(int lane) {
    // Lane 0 is top, lane 1 is middle, lane 2 is bottom
    // Distribute lanes evenly with padding
    double laneHeight = (gameRef.size.y - size.y) / (totalLanes - 1);
    return lane * laneHeight + size.y / 2;
  }

  /// Switch to a different lane
  void switchToLane(int targetLane) {
    if (_isSwitchingLanes || targetLane < 0 || targetLane >= totalLanes) {
      return;
    }
    
    _currentLane = targetLane;
    _targetY = _calculateLaneY(_currentLane);
    _isSwitchingLanes = true;
    _animationState = PlayerAnimationState.jump;
    _animationTime = 0.0;
  }

  /// Switch to next lane (down)
  void switchToNextLane() {
    if (_currentLane < totalLanes - 1) {
      switchToLane(_currentLane + 1);
    }
  }

  /// Switch to previous lane (up)
  void switchToPreviousLane() {
    if (_currentLane > 0) {
      switchToLane(_currentLane - 1);
    }
  }

  /// Toggle between lanes (simple up/down)
  void toggleLane() {
    if (_currentLane == 0) {
      switchToNextLane();
    } else if (_currentLane == totalLanes - 1) {
      switchToPreviousLane();
    } else {
      // Switch to opposite lane
      switchToLane(_currentLane == 1 ? 0 : 1);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _animationTime += dt;
    
    // Update animation state
    _updateAnimations(dt);
    
    // Handle lane switching movement
    if (_isSwitchingLanes) {
      _updateMovement(dt);
    } else if (_animationState != PlayerAnimationState.jump) {
      // Return to idle when not moving
      _animationState = PlayerAnimationState.idle;
    }
    
    // Enforce collision bounds (keep player on screen)
    _enforceBounds();
  }
  
  void _updateAnimations(double dt) {
    switch (_animationState) {
      case PlayerAnimationState.idle:
        // Idle animation: subtle pulsing
        _idlePulseScale = 1.0 + math.sin(_animationTime * _idlePulseSpeed) * _idlePulseAmount;
        _animatedSize = Vector2(_baseSize * _idlePulseScale, _baseSize * _idlePulseScale);
        size.setValues(_animatedSize.x, _animatedSize.y);
        break;
        
      case PlayerAnimationState.move:
        // Move animation: slight stretch in direction of movement
        double moveScale = 1.0 + 0.15 * (1.0 - (_animationTime / _jumpDuration).clamp(0.0, 1.0));
        _animatedSize = Vector2(_baseSize * moveScale * 0.9, _baseSize * moveScale * 1.1);
        size.setValues(_animatedSize.x, _animatedSize.y);
        break;
        
      case PlayerAnimationState.jump:
        // Jump animation: bounce effect
        double jumpProgress = (_animationTime / _jumpDuration).clamp(0.0, 1.0);
        // Parabolic jump curve
        _jumpHeight = _maxJumpHeight * 4 * jumpProgress * (1.0 - jumpProgress);
        
        // Scale effect during jump
        double jumpScale = 1.0 + 0.2 * math.sin(jumpProgress * math.pi);
        _animatedSize = Vector2(_baseSize * jumpScale, _baseSize * jumpScale);
        size.setValues(_animatedSize.x, _animatedSize.y);
        
        // End jump animation
        if (jumpProgress >= 1.0 && !_isSwitchingLanes) {
          _animationState = PlayerAnimationState.idle;
          _jumpHeight = 0.0;
          _animationTime = 0.0;
        }
        break;
    }
  }
  
  void _updateMovement(double dt) {
    double distance = (_targetY - position.y).abs();
    
    if (distance < 5.0) {
      // Reached target lane
      position.y = _targetY;
      _isSwitchingLanes = false;
      
      // Transition to idle after a brief moment
      if (_animationState == PlayerAnimationState.jump && _jumpHeight < 1.0) {
        _animationState = PlayerAnimationState.idle;
        _animationTime = 0.0;
      }
    } else {
      // Move towards target lane
      _animationState = PlayerAnimationState.move;
      double direction = _targetY > position.y ? 1.0 : -1.0;
      position.y += direction * _switchSpeed * dt;
      
      // Clamp to ensure we don't overshoot
      if ((direction > 0 && position.y > _targetY) ||
          (direction < 0 && position.y < _targetY)) {
        position.y = _targetY;
        _isSwitchingLanes = false;
        _animationState = PlayerAnimationState.idle;
      }
    }
  }
  
  /// Enforce collision bounds to keep player on screen
  void _enforceBounds() {
    // Keep player within screen bounds
    double minX = size.x / 2;
    double maxX = gameRef.size.x - size.x / 2;
    double minY = size.y / 2;
    double maxY = gameRef.size.y - size.y / 2;
    
    // Horizontal bounds (shouldn't change, but enforce anyway)
    position.x = position.x.clamp(minX, maxX);
    
    // Vertical bounds - ensure player doesn't go off screen
    // During lane switching, we allow temporary movement outside bounds
    // but clamp at the end
    if (!_isSwitchingLanes) {
      position.y = position.y.clamp(minY, maxY);
      
      // Ensure target Y is also within bounds
      _targetY = _targetY.clamp(minY, maxY);
    } else {
      // While switching, allow slight overshoot but keep reasonable bounds
      position.y = position.y.clamp(minY - 10, maxY + 10);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Apply size scaling from animations
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(_animatedSize.x / _baseSize, _animatedSize.y / _baseSize);
    
    // Apply jump offset
    canvas.translate(0, -_jumpHeight);
    
    // Draw player body with skin colors
    _drawPlayerBody(canvas);
    
    canvas.restore();
  }
  
  void _drawPlayerBody(Canvas canvas) {
    // Main body rectangle
    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: _baseSize,
      height: _baseSize,
    );
    
    // Draw main body with gradient effect
    final paint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8.0)),
      paint,
    );
    
    // Draw accent overlay based on animation state
    Color accentColor = skin.accentColor;
    if (_animationState == PlayerAnimationState.jump) {
      accentColor = Colors.white.withOpacity(0.6);
    } else if (_animationState == PlayerAnimationState.move) {
      accentColor = skin.secondaryColor;
    }
    
    // Draw top accent (head area)
    final accentRect = Rect.fromCenter(
      center: Offset(0, -_baseSize * 0.15),
      width: _baseSize * 0.7,
      height: _baseSize * 0.4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(accentRect, const Radius.circular(6.0)),
      Paint()..color = accentColor,
    );
    
    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8.0)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    
    // Draw eyes (simple circles)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(-_baseSize * 0.15, -_baseSize * 0.1),
      _baseSize * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(_baseSize * 0.15, -_baseSize * 0.1),
      _baseSize * 0.08,
      eyePaint,
    );
    
    // Draw pupils
    final pupilPaint = Paint()..color = skin.secondaryColor;
    canvas.drawCircle(
      Offset(-_baseSize * 0.15, -_baseSize * 0.1),
      _baseSize * 0.04,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(_baseSize * 0.15, -_baseSize * 0.1),
      _baseSize * 0.04,
      pupilPaint,
    );
  }

  @override
  bool onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Collision will be handled by the game scene
    return true;
  }

  bool hasCollided() {
    // This will be checked by collision detection
    return false;
  }
}

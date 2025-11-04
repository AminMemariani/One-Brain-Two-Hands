import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'player.dart';
import '../core/audio_manager.dart';

class TapHandler extends PositionComponent with HasGameRef, TapCallbacks {
  final Player leftPlayer;
  final Player rightPlayer;
  final bool Function()? shouldHandleTap;

  TapHandler({
    required this.leftPlayer,
    required this.rightPlayer,
    this.shouldHandleTap,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Make component cover the entire game area to receive all tap/mouse events
    size = gameRef.size;
    position = Vector2.zero();
  }

  @override
  bool onTapDown(TapDownEvent event) {
    return _handleInput(event.localPosition);
  }

  bool _handleInput(Vector2 localPosition) {
    if (shouldHandleTap != null && !shouldHandleTap!()) {
      return false;
    }

    // Determine which side of screen was tapped/clicked
    double screenWidth = gameRef.size.x;
    double inputX = localPosition.x;

    // Left half of screen controls left player
    if (inputX < screenWidth / 2) {
      AudioManager().playTap();
      leftPlayer.toggleLane();
    }
    // Right half of screen controls right player
    else {
      AudioManager().playTap();
      rightPlayer.toggleLane();
    }

    return true;
  }
  
  // Ensure component covers the full game area to receive all events
  @override
  bool containsPoint(Vector2 point) => true;
}


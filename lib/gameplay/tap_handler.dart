import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'player.dart';
import '../core/audio_manager.dart';

class TapHandler extends Component with HasGameRef, TapCallbacks {
  final Player leftPlayer;
  final Player rightPlayer;
  final bool Function()? shouldHandleTap;

  TapHandler({
    required this.leftPlayer,
    required this.rightPlayer,
    this.shouldHandleTap,
  });

  @override
  bool onTapDown(TapDownEvent event) {
    if (shouldHandleTap != null && !shouldHandleTap!()) {
      return false;
    }

    // Determine which side of screen was tapped
    double screenWidth = gameRef.size.x;
    double tapX = event.localPosition.x;

    // Left half of screen controls left player
    if (tapX < screenWidth / 2) {
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
}


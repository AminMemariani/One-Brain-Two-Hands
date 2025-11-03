import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:one_brain_two_hands/gameplay/obstacle.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';

class _DummyPlayer extends Player {
  _DummyPlayer(PlayerSide side)
      : super(side: side, screenWidth: 800, screenHeight: 600);
}

void main() {
  test('Obstacle triggers collision callback once for matching player side', () {
    PlayerSide collidedSide = PlayerSide.left;
    int callbackCount = 0;

    final obstacle = Obstacle(
      position: Vector2.zero(),
      size: Vector2(40, 60),
      side: PlayerSide.left,
      gameSpeed: 1.0,
      onPlayerCollision: (side) {
        collidedSide = side;
        callbackCount++;
      },
    );

    final matchingPlayer = _DummyPlayer(PlayerSide.left);
    final otherPlayer = _DummyPlayer(PlayerSide.right);

    final result1 = obstacle.onCollisionStart({}, matchingPlayer);
    final result2 = obstacle.onCollisionStart({}, matchingPlayer);
    final result3 = obstacle.onCollisionStart({}, otherPlayer);

    expect(result1, isTrue);
    expect(result2, isFalse);
    expect(result3, isFalse);
    expect(callbackCount, 1);
    expect(collidedSide, PlayerSide.left);
  });
}



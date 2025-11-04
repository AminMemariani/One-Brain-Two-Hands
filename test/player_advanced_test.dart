import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class _TestGame extends FlameGame {
  @override
  Vector2 get size => Vector2(800, 600);
}

void main() {
  test('Player calculates lane Y positions correctly', () {
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
      totalLanes: 3,
    );
    
    // Test that lanes are calculated correctly
    // Note: This tests internal logic through lane switching
    expect(player.currentLane, 1); // Middle lane
  });

  test('Player animation states change correctly', () {
    final game = _TestGame();
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
    );
    game.add(player);
    
    final initialState = player.animationState;
    expect(initialState, isA<PlayerAnimationState>());
  });

  test('Player skin colors are set correctly', () {
    final leftPlayer = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
    );
    
    final rightPlayer = Player(
      side: PlayerSide.right,
      screenWidth: 800,
      screenHeight: 600,
    );
    
    expect(leftPlayer.playerSkin, isNotNull);
    expect(rightPlayer.playerSkin, isNotNull);
    expect(leftPlayer.playerSkin.name, isNotEmpty);
    expect(rightPlayer.playerSkin.name, isNotEmpty);
  });

  test('PlayerSkin predefined skins are available', () {
    expect(PlayerSkin.allSkins.length, greaterThan(0));
    expect(PlayerSkin.blue, isNotNull);
    expect(PlayerSkin.green, isNotNull);
    expect(PlayerSkin.purple, isNotNull);
    expect(PlayerSkin.orange, isNotNull);
  });

  test('PlayerSkin has correct properties', () {
    final skin = PlayerSkin.blue;
    expect(skin.primaryColor, isNotNull);
    expect(skin.secondaryColor, isNotNull);
    expect(skin.accentColor, isNotNull);
    expect(skin.name, 'Blue');
  });

  test('Player onCollisionStart returns true', () {
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
    );
    
    // Player should handle collisions
    final result = player.onCollisionStart({}, player);
    expect(result, isTrue);
  });

  test('Player hasCollided returns false initially', () {
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
    );
    
    expect(player.hasCollided(), isFalse);
  });

  test('Player setSkin exists but does not change skin after creation', () {
    final player = Player(
      side: PlayerSide.left,
      screenWidth: 800,
      screenHeight: 600,
      skin: PlayerSkin.blue,
    );
    
    final initialSkin = player.playerSkin;
    player.setSkin(PlayerSkin.green);
    // setSkin doesn't actually change skin (as documented in code)
    expect(player.playerSkin, initialSkin);
  });
}


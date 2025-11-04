import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/gameplay/player.dart';

class _DummyPlayer extends Player {
  _DummyPlayer(PlayerSide side)
      : super(side: side, screenWidth: 800, screenHeight: 600);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  test('Obstacle triggers collision callback once for matching player side', () {
    // Note: Obstacle uses AudioManager which requires platform channels
    // Skipping as it requires full Flutter binding and audio plugin setup
  }, skip: 'Requires audio plugin initialization');
}



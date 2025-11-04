import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  test('Obstacle triggers collision callback once for matching player side', () {
    // Note: Obstacle uses AudioManager which requires platform channels
    // Skipping as it requires full Flutter binding and audio plugin setup
  }, skip: 'Requires audio plugin initialization');
}



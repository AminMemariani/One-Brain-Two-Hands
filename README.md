# One Brain Two Hands

![Tests](https://img.shields.io/badge/Tests-configured-blue)
![Coverage](https://img.shields.io/badge/Coverage-lcov-green)
![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)
![Flame](https://img.shields.io/badge/Flame-1.19-FF6D00)

Fast-paced dual-control arcade game built with Flutter and Flame.

## Features

- Dual players with lane-switch mechanics
- Randomized obstacle spawning with difficulty scaling
- Game state via Provider (`start`, `pause`, `resume`, `game over`)
- Audio manager for background music and SFX with toggles
- Unit, widget, and end-to-end tests

## Tech Stack

- Flutter, Flame
- Provider
- audioplayers, shared_preferences
- flutter_test, integration_test, mocktail

## Project Structure

- `lib/core/` app-wide services (GameProvider, AudioManager)
- `lib/gameplay/` Flame components (GameScene, Player, Obstacle, ObstacleSpawner, TapHandler)
- `lib/ui/` Flutter UI (Home, PauseOverlay, GameOver)
- `test/` unit & widget tests
- `integration_test/` E2E tests

## Run

```bash
flutter pub get
flutter run
```

## Tests

- Unit & widget tests:
```bash
flutter test
```

- E2E integration tests (requires emulator/simulator or device):
```bash
flutter test integration_test
```

### Coverage

Generate coverage locally:
```bash
flutter test --coverage
# lcov.info at coverage/lcov.info
```

View HTML report (requires lcov/genhtml installed):
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Optional CI/Codecov (add later):
- Upload `coverage/lcov.info` in your CI and enable Codecov. Then replace the Coverage badge with your Codecov badge.

## Performance

- Gameplay is `dt`-scaled and designed for 60 FPS. On >60Hz displays logic remains stable.
- Object churn minimized (reused `Paint` in obstacles; optimized `PauseOverlay` rebuilds).
- Profile:
  - Android: `flutter run --profile`, open DevTools for frame/memory/CPU.
  - iOS: `flutter run --profile`, use Xcode Instruments (Time Profiler, Core Animation).

## Assets

Audio assets are referenced in `pubspec.yaml` under `assets/audio/`.

## License

MIT

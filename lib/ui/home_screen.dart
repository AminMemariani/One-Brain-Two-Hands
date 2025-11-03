import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import '../core/game_provider.dart';
import '../gameplay/game_scene.dart';
import 'game_over_screen.dart';
import 'pause_overlay.dart';
import '../core/audio_manager.dart';
import '../core/audio_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameScene? _gameScene;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();
    _gameScene = GameScene();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      _gameScene!.initializeWithProvider(gameProvider);

      // Listen to provider changes to pause/resume Flame engine
      _providerListener = () {
        if (!gameProvider.isPlaying || gameProvider.isPaused) {
          _gameScene?.pauseEngine();
          // Stop music when paused or not playing
          AudioManager().stopBackgroundMusic();
        } else {
          _gameScene?.resumeEngine();
          // Start/ensure background music when playing
          AudioManager().playBackgroundMusic();
        }
      };
      gameProvider.addListener(_providerListener!);

      // Set initial engine state
      if (!gameProvider.isPlaying || gameProvider.isPaused) {
        _gameScene?.pauseEngine();
      } else {
        _gameScene?.resumeEngine();
      }
    });
  }

  @override
  void dispose() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (_providerListener != null) {
      gameProvider.removeListener(_providerListener!);
      _providerListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Show home UI when not playing
          if (!gameProvider.isPlaying) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'One Brain Two Hands',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Best: ${gameProvider.highScore}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        gameProvider.startGame();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Text('Play'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show game over UI
          if (gameProvider.isGameOver) {
            return const GameOverScreen();
          }

          // In-game UI
          return Stack(
            children: [
              if (_gameScene != null)
                GameWidget<GameScene>.controlled(
                  gameFactory: () => _gameScene!,
                ),
              if (gameProvider.isPaused)
                PauseOverlay(game: _gameScene),
            ],
          );
        },
      ),
    );
  }
}

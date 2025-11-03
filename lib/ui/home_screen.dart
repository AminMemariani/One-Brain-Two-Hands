import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import '../core/game_provider.dart';
import '../gameplay/game_scene.dart';
import 'game_over_screen.dart';
import 'pause_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameScene? _gameScene;

  @override
  void initState() {
    super.initState();
    _gameScene = GameScene();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      _gameScene!.initializeWithProvider(gameProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isGameOver) {
            return const GameOverScreen();
          }
          
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

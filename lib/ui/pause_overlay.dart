import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_provider.dart';
import '../gameplay/game_scene.dart';

class PauseOverlay extends StatelessWidget {
  final GameScene? game;

  const PauseOverlay({super.key, this.game});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Paused',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                game?.resumeGame();
              },
              child: const Text('Resume'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Return to home
                gameProvider.resetScore();
              },
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}

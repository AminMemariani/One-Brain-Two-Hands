import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_provider.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${gameProvider.score}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'High Score: ${gameProvider.highScore}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                gameProvider.startGame();
              },
              child: const Text('Play Again'),
            ),
          const SizedBox(height: 12),
          // Local-only reward: show placeholder and grant next-run bonus
          OutlinedButton(
            onPressed: () async {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const _LocalRewardDialog();
                },
              );
              gameProvider.grantNextRunBonus(100);
            },
            child: const Text('Watch Bonus (Local)'),
          ),
          const SizedBox(height: 24),
          if (gameProvider.achievements.contains('survive_30s'))
            const Text(
              'Achievement unlocked: Survive 30 seconds',
              style: TextStyle(color: Colors.amber, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalRewardDialog extends StatefulWidget {
  const _LocalRewardDialog();
  @override
  State<_LocalRewardDialog> createState() => _LocalRewardDialogState();
}

class _LocalRewardDialogState extends State<_LocalRewardDialog> {
  int _seconds = 3;
  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _seconds -= 1;
      });
      if (_seconds <= 0) {
        Navigator.of(context).pop();
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bonus Reward',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Local placeholder ad... (no network)',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Continuing in $_seconds',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

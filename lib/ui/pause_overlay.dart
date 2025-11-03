import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_provider.dart';
import '../core/audio_manager.dart';
import '../gameplay/game_scene.dart';

class PauseOverlay extends StatefulWidget {
  final GameScene? game;

  const PauseOverlay({super.key, this.game});

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
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
            // Audio toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: ValueNotifier(AudioManager().isMusicEnabled),
                    builder: (context, value, _) {
                      return Row(
                        children: [
                          const Text(
                            'Music',
                            style: TextStyle(color: Colors.white),
                          ),
                          Switch(
                            value: AudioManager().isMusicEnabled,
                            onChanged: (v) async {
                              await AudioManager().setMusicEnabled(v);
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder(
                    valueListenable: ValueNotifier(AudioManager().isSoundEnabled),
                    builder: (context, value, _) {
                      return Row(
                        children: [
                          const Text(
                            'SFX',
                            style: TextStyle(color: Colors.white),
                          ),
                          Switch(
                            value: AudioManager().isSoundEnabled,
                            onChanged: (v) {
                              AudioManager().setSoundEnabled(v);
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.game?.resumeGame();
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

import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> playMusic(String path, {bool loop = true}) async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(path));
      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      // Handle audio errors gracefully
      print('Error playing music: $e');
    }
  }

  Future<void> playSound(String path) async {
    if (!_isSoundEnabled) return;
    try {
      await _soundEffectPlayer.play(AssetSource(path));
    } catch (e) {
      // Handle audio errors gracefully
      print('Error playing sound: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void dispose() {
    _musicPlayer.dispose();
    _soundEffectPlayer.dispose();
  }
}

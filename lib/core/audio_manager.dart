import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  bool get isMusicEnabled => _musicEnabled;
  bool get isSoundEnabled => _sfxEnabled;

  // Asset paths (ensure these exist in pubspec assets)
  static const String _bgMusic = 'assets/audio/music_bg.mp3';
  static const String _tapSfx = 'assets/audio/tap.wav';
  static const String _collisionSfx = 'assets/audio/crash.mp3';
  static const String _scoreSfx = 'assets/audio/score.wav';

  Future<void> init() async {
    // Configure players
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
  }

  // Background music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(_bgMusic));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('AudioManager: failed to play bg music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  // Sound effects
  Future<void> playTap() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(_tapSfx));
    } catch (e) {
      print('AudioManager: failed to play tap: $e');
    }
  }

  Future<void> playCollision() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(_collisionSfx));
    } catch (e) {
      print('AudioManager: failed to play collision: $e');
    }
  }

  Future<void> playScore() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(_scoreSfx));
    } catch (e) {
      print('AudioManager: failed to play score: $e');
    }
  }

  // Toggles
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      await stopBackgroundMusic();
    } else {
      await playBackgroundMusic();
    }
  }

  void setSoundEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  // Convenience master toggle
  Future<void> setMuted(bool muted) async {
    await setMusicEnabled(!muted);
    setSoundEnabled(!muted);
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

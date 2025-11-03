import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  // Game state fields
  bool _isPlaying = false;
  bool _isPaused = false;
  int _score = 0;
  int _highScore = 0;
  double _gameSpeed = 1.0;
  double _elapsedSeconds = 0.0;
  final Set<String> _achievements = <String>{};
  bool _adsRemoved = false;
  int _pendingBonusScore = 0;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get score => _score;
  int get highScore => _highScore;
  double get gameSpeed => _gameSpeed;
  double get elapsedSeconds => _elapsedSeconds;
  Set<String> get achievements => _achievements;
  bool get adsRemoved => _adsRemoved;

  // Legacy getter for compatibility
  bool get isGameOver => !_isPlaying && _score > 0;

  GameProvider() {
    _loadHighScore();
    _loadAdsRemoved();
    _loadAchievements();
  }

  /// Load high score from SharedPreferences
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('high_score') ?? 0;
    notifyListeners();
  }

  /// Save high score to SharedPreferences
  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', _highScore);
  }

  Future<void> _loadAdsRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool('ads_removed') ?? false;
  }

  Future<void> _saveAdsRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_removed', _adsRemoved);
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('achievements') ?? <String>[];
    _achievements
      ..clear()
      ..addAll(list);
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('achievements', _achievements.toList());
  }

  /// Start a new game
  void startGame() {
    _isPlaying = true;
    _isPaused = false;
    _score = 0;
    _elapsedSeconds = 0.0;
    _gameSpeed = 1.0;
    if (_pendingBonusScore > 0) {
      _score += _pendingBonusScore;
      _pendingBonusScore = 0;
    }
    notifyListeners();
  }

  /// Pause the current game
  void pauseGame() {
    if (_isPlaying && !_isPaused) {
      _isPaused = true;
      notifyListeners();
    }
  }

  /// Resume the paused game
  void resumeGame() {
    if (_isPlaying && _isPaused) {
      _isPaused = false;
      notifyListeners();
    }
  }

  /// End the current game
  void endGame() {
    if (_isPlaying) {
      _isPlaying = false;
      _isPaused = false;
      
      // Update high score if current score is higher
      if (_score > _highScore) {
        _highScore = _score;
        _saveHighScore();
      }
      
      notifyListeners();
    }
  }

  /// Increase game difficulty by increasing game speed
  void increaseDifficulty() {
    // Increase speed by 0.1 up to a maximum of 3.0
    if (_gameSpeed < 3.0) {
      _gameSpeed = (_gameSpeed + 0.1).clamp(1.0, 3.0);
      notifyListeners();
    }
  }

  /// Smoothly adjust game speed by a delta, clamped to [1.0, 3.0]
  void adjustGameSpeed(double delta) {
    final newSpeed = (_gameSpeed + delta).clamp(1.0, 3.0);
    if (newSpeed != _gameSpeed) {
      _gameSpeed = newSpeed;
      notifyListeners();
    }
  }

  /// Increment score and update high score if necessary
  void incrementScore(int points) {
    if (_isPlaying) {
      _score += points;
      
      // Update high score if current score is higher
      if (_score > _highScore) {
        _highScore = _score;
        _saveHighScore();
      }
      
      notifyListeners();
    }
  }

  /// Track elapsed time for achievements
  void incrementElapsed(double dtSeconds) {
    if (!_isPlaying) return;
    _elapsedSeconds += dtSeconds;
    // Achievement: survive 30 seconds
    if (_elapsedSeconds >= 30.0 && !_achievements.contains('survive_30s')) {
      _achievements.add('survive_30s');
      _saveAchievements();
      notifyListeners();
    }
  }

  /// Reset game state (for compatibility with existing code)
  void resetScore() {
    _score = 0;
    _isPlaying = false;
    _isPaused = false;
    _gameSpeed = 1.0;
    _elapsedSeconds = 0.0;
    notifyListeners();
  }

  /// Set game over state (for compatibility with existing code)
  void setGameOver(bool value) {
    if (value) {
      endGame();
    } else {
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Stub: Remove ads locally
  Future<void> removeAdsLocally() async {
    _adsRemoved = true;
    await _saveAdsRemoved();
    notifyListeners();
  }

  /// Local-only rewarded bonus: grant extra points on next start
  void grantNextRunBonus(int bonus) {
    _pendingBonusScore = bonus;
    notifyListeners();
  }

  /// Toggle pause state (for compatibility with existing code)
  void togglePause() {
    if (_isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  /// Set paused state directly (for compatibility with existing code)
  void setPaused(bool value) {
    if (value) {
      pauseGame();
    } else {
      resumeGame();
    }
  }
}

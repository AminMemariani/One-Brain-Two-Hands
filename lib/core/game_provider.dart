import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  // Game state fields
  bool _isPlaying = false;
  bool _isPaused = false;
  int _score = 0;
  int _highScore = 0;
  double _gameSpeed = 1.0;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get score => _score;
  int get highScore => _highScore;
  double get gameSpeed => _gameSpeed;

  // Legacy getter for compatibility
  bool get isGameOver => !_isPlaying && _score > 0;

  GameProvider() {
    _loadHighScore();
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

  /// Start a new game
  void startGame() {
    _isPlaying = true;
    _isPaused = false;
    _score = 0;
    _gameSpeed = 1.0;
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

  /// Reset game state (for compatibility with existing code)
  void resetScore() {
    _score = 0;
    _isPlaying = false;
    _isPaused = false;
    _gameSpeed = 1.0;
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

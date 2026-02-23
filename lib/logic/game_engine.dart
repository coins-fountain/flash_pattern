import 'dart:math';

import 'package:flash_pattern/logic/game_state.dart';

class GameEngine {
  final List<int> _pattern = [];
  final List<int> _userInput = [];

  final double _baseDelay = 500;
  final double _minDelay = 100;

  int get level => _pattern.length;

  int get gridSize => (2 + (level ~/ 4)).clamp(2, 7);

  int get totalTiles => gridSize * gridSize;

  List<int> get pattern => List.unmodifiable(_pattern);

  double get currentDelay =>
      (_baseDelay - level * 20).clamp(_minDelay, _baseDelay);

  void start() {
    _pattern.clear();
    _userInput.clear();
    _addStep();
  }

  void nextLevel() {
    _userInput.clear();
    _addStep();
  }

  void reset() {
    _pattern.clear();
    _userInput.clear();
  }

  void retry() {
    _userInput.clear();
  }

  void _addStep() {
    _pattern.add(Random().nextInt(totalTiles));
  }

  GameStepResult input(int index) {
    _userInput.add(index);

    int currentIndex = _userInput.length - 1;

    if (_userInput[currentIndex] != _pattern[currentIndex]) {
      return GameStepResult.wrong;
    }

    if (_userInput.length == _pattern.length) {
      return GameStepResult.levelComplete;
    }

    return GameStepResult.correct;
  }
}
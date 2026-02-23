import 'package:flash_pattern/data/repositories/get_highscore.dart';
import 'package:flash_pattern/data/repositories/save_highscore.dart';
import 'package:flash_pattern/logic/game_engine.dart';
import 'package:flash_pattern/logic/game_state.dart';
import 'package:get/get.dart';


class GameController extends GetxController {
  final GameEngine engine;
  final GetHighScore getHighScore;
  final SaveHighScore saveHighScore;

  GameController({
    required this.engine,
    required this.getHighScore,
    required this.saveHighScore,
  });


  var gridSize = 2.obs;
  var isGameStarted = false.obs;
  var isShowingPattern = false.obs;
  var highScore = 0.obs;
  var activeIndex = Rxn<int>();

  int get currentLevel => engine.level;

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    highScore.value = await getHighScore();
  }

  Future<void> startGame() async {
    engine.start();
    gridSize.value = engine.gridSize;
    isGameStarted.value = true;
    await _showPattern();
  }

  Future<void> nextLevel() async {
    engine.nextLevel();
    gridSize.value = engine.gridSize;
    await _showPattern();
  }

  Future<void> _showPattern() async {
    isShowingPattern.value = true;

    for (final index in engine.pattern) {
      activeIndex.value = index;

      print("engine dellay " + engine.currentDelay.toInt().toString());

      await Future.delayed(
        Duration(milliseconds: engine.currentDelay.toInt()),
      );

      activeIndex.value = null;

      await Future.delayed(
        Duration(milliseconds: engine.currentDelay.toInt()),
      );
    }

    isShowingPattern.value = false;
  }

  Future<void> onTileTap(int index) async {
    if (!isGameStarted.value || isShowingPattern.value) return;

    final result = engine.input(index);

    switch (result) {
      case GameStepResult.wrong:
        await _gameOver();
        break;

      case GameStepResult.levelComplete:
        await Future.delayed(const Duration(milliseconds: 400));
        await nextLevel();
        break;

      case GameStepResult.correct:
        break;
    }
  }

  Future<void> _gameOver() async {
    isGameStarted.value = false;

    if (currentLevel > highScore.value) {
      highScore.value = currentLevel;
      await saveHighScore(currentLevel);
    }
    gridSize.value = engine.gridSize;
    engine.reset();
  }
}
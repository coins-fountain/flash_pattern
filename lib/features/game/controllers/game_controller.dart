import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/data/repositories/get_highscore.dart';
import 'package:flash_pattern/data/repositories/save_highscore.dart';
import 'package:flash_pattern/features/game/controllers/ads_controller/ads_controller.dart';
import 'package:flash_pattern/features/game/controllers/ads_controller/consent_controller.dart';
import 'package:flash_pattern/logic/game_engine.dart';
import 'package:flash_pattern/logic/game_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final AdController adController = Get.find<AdController>();
  final ConsentController consentController = Get.find<ConsentController>();

  int get currentLevel => engine.level;
  var userTapIndex = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
    Future.delayed(const Duration(milliseconds: 300), () {
      startGame();
    });
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

  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://coins-fountain.github.io/privacy-policy-games/',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _showPattern() async {
    isShowingPattern.value = true;

    for (final index in engine.pattern) {
      activeIndex.value = index;
      await Future.delayed(Duration(milliseconds: engine.currentDelay.toInt()));

      activeIndex.value = null;

      await Future.delayed(Duration(milliseconds: engine.currentDelay.toInt()));
    }
    isShowingPattern.value = false;
  }

  Future<void> onTileTap(int index) async {
    if (!isGameStarted.value ||
        isShowingPattern.value ||
        userTapIndex.value != null) {
      debugPrint(
        "Input ditolak: GameStarted=${isGameStarted.value}, ShowingPattern=${isShowingPattern.value}",
      );
      return;
    }

    userTapIndex.value = index;
    Future.delayed(const Duration(milliseconds: 150), () {
      userTapIndex.value = null;
    });
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
    final finalScore = currentLevel;

    if (finalScore > highScore.value) {
      highScore.value = finalScore;
      await saveHighScore(finalScore);
    }

    await _showGameOverDialog(finalScore);
  }

  Future<void> _showGameOverDialog(int score) async {
    await Get.dialog(
      Dialog(
        backgroundColor: AppColors.alertGameOver.withValues(alpha: 0.90),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Game Over",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.tileActive, width: 2),
                        foregroundColor: AppColors.tileActive,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        _retrySameGrid();
                      },
                      child: const Text(
                        "Try Again",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tileActive,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.tileActive.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        _restartFromBeginning();
                      },
                      child: const Text(
                        "New Game",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _retrySameGrid() async {
    isGameStarted.value = false;

    // We pass a callback that is guaranteed to run whether the ad is shown,
    // fails to show, or isn't ready.
    adController.showInterstitial(
      onClosed: () async {
        engine.retry();
        isGameStarted.value = true;
        await _showPattern();
      },
    );
  }

  Future<void> _restartFromBeginning() async {
    engine.reset();
    gridSize.value = engine.gridSize;
    isGameStarted.value = true;
    await startGame();
  }
}

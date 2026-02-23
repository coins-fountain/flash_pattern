import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/data/repositories/get_highscore.dart';
import 'package:flash_pattern/data/repositories/save_highscore.dart';
import 'package:flash_pattern/core/services/ad_service.dart';
import 'package:flash_pattern/core/services/consent_service.dart';
import 'package:flash_pattern/features/game/views/intro_screen.dart';
import 'package:flash_pattern/core/logic/game_engine.dart';
import 'package:flash_pattern/core/logic/game_state.dart';
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
  var score = 0.obs;
  var activeIndex = Rxn<int>();
  final AdService adService = Get.find<AdService>();
  final ConsentService consentService = Get.find<ConsentService>();

  bool isReviveUsed = false;
  var reviveCountdown = 10.obs;
  bool _isReviveDialogActionTaken = false;

  int get currentLevel => engine.level;
  var userTapIndex = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    highScore.value = await getHighScore();
  }

  Future<void> startGame() async {
    isReviveUsed = false;
    engine.start();
    gridSize.value = engine.gridSize;
    score.value = engine.level;
    isGameStarted.value = true;
    await _showPattern();
  }

  Future<void> nextLevel() async {
    engine.nextLevel();
    gridSize.value = engine.gridSize;
    score.value = engine.level;
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

    if (!isReviveUsed && finalScore > 0) {
      await _showReviveDialog();
    } else {
      await _showGameOverDialog(finalScore, highScore.value);
      adService.showInterstitial();
    }
  }

  Future<void> _showReviveDialog() async {
    reviveCountdown.value = 10;
    _isReviveDialogActionTaken = false;

    // Start countdown timer
    final timer = Stream.periodic(const Duration(seconds: 1), (i) => 10 - i - 1)
        .take(10)
        .listen((val) {
          reviveCountdown.value = val;
          if (val <= 0 && !_isReviveDialogActionTaken) {
            _isReviveDialogActionTaken = true;
            Get.back(); // Close dialog
            _showGameOverDialog(currentLevel, highScore.value);
            adService.showInterstitial();
          }
        });

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3333).withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "REVIVE?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Obx(
                    () => SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: reviveCountdown.value / 10,
                        color: Colors.orange,
                        backgroundColor: Colors.white10,
                        strokeWidth: 6,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      "${reviveCountdown.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Watch a short ad to continue your streak!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _isReviveDialogActionTaken = true;
                    timer.cancel();
                    Get.back();
                    _reviveWithAd();
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.black),
                  label: const Text(
                    "WATCH AD",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  _isReviveDialogActionTaken = true;
                  timer.cancel();
                  Get.back();
                  await _showGameOverDialog(currentLevel, highScore.value);
                  adService.showInterstitial();
                },
                child: const Text(
                  "NO THANKS",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _reviveWithAd() {
    bool earned = false;
    adService.showRewardedAd(
      onRewardEarned: () {
        earned = true;
      },
      onAdDismissed: () {
        if (earned) {
          isReviveUsed = true;
          engine.retry();
          _showPattern();
        } else {
          _showGameOverDialog(currentLevel, highScore.value);
          adService.showInterstitial();
        }
      },
      onAdFailed: () {
        _showGameOverDialog(currentLevel, highScore.value);
        adService.showInterstitial();
      },
    );
  }

  Future<void> _showGameOverDialog(int score, int highScoreValue) async {
    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3333).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.tileActive.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tileActive.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.tileActive,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "GAME OVER",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreRow("Current Score", score.toString(), isMain: true),
              const SizedBox(height: 12),
              _buildScoreRow("Best Record", highScoreValue.toString()),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      label: "HOME",
                      icon: Icons.home_rounded,
                      isOutlined: true,
                      onPressed: () {
                        Get.back();
                        Get.offAll(() => const IntroScreen());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogButton(
                      label: "RETRY",
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        Get.back();
                        _restartFromBeginning();
                      },
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

  Widget _buildScoreRow(String label, String value, {bool isMain = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isMain ? AppColors.tileActive : Colors.white,
              fontSize: isMain ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tileActive,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _restartFromBeginning() async {
    isReviveUsed = false;
    engine.reset();
    gridSize.value = engine.gridSize;
    score.value = 0;
    isGameStarted.value = true;
    await startGame();
  }
}

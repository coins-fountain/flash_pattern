import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/core/services/consent_service.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flash_pattern/features/game/views/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameScreen extends GetView<GameController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consentService = Get.find<ConsentService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Obx(
              () => Text(
                "Level: ${controller.score.value}",
                style: TextStyle(
                  color: controller.score.value > controller.highScore.value
                      ? AppColors.tileActive
                      : AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                "High Score: ${controller.highScore.value}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: controller.isShowingPattern.value
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.isShowingPattern.value
                      ? "MEMORIZING..."
                      : "YOUR TURN!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: controller.isShowingPattern.value
                        ? Colors.orange
                        : Colors.green,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() {
              return AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      controller.gridSize.value * controller.gridSize.value,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller.gridSize.value,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return GameTile(index: index, controller: controller);
                  },
                ),
              );
            }),
            Obx(() {
              if (!consentService.isRequestLocationInEeaOrUk.value) {
                return const SizedBox();
              }
              return Column(
                children: [
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await consentService.showPrivacyOptions();
                    },
                    child: const Text(
                      "Privacy Settings Ads",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      controller.openPrivacyPolicy();
                    },
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

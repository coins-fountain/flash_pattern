import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flash_pattern/features/game/view/widget/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameScreen extends GetView<GameController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Obx(() => Text(
              "High Score: ${controller.highScore.value}",
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 18),
            )),
            const SizedBox(height: 40),
            Obx(() {
              return AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.gridSize.value *  controller.gridSize.value,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller.gridSize.value,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return GameTile(
                      index: index,
                      controller: controller,
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 40),
            Obx(() => !controller.isGameStarted.value
                ? ElevatedButton(
              onPressed: controller.startGame,
              child: const Text("Start Game"),
            )
                : const SizedBox())
          ],
        ),
      ),
    );
  }
}
import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameTile extends StatelessWidget {
  final int index;
  final GameController controller;

  const GameTile({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive =
          controller.activeIndex.value == index;

      return GestureDetector(
        onTap: () => controller.onTileTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.tileActive
                : AppColors.tileInactive,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }
}
import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameTile extends StatefulWidget {
  final int index;
  final GameController controller;

  const GameTile({super.key, required this.index, required this.controller});

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => widget.controller.onTileTap(widget.index),
      child: Obx(() {
        bool isActive =
            widget.controller.activeIndex.value == widget.index ||
            widget.controller.userTapIndex.value == widget.index;

        return AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.tileActive
                  : AppColors.tileInactive.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(
                12,
              ), // Lebih rounded lebih modern
              border: Border.all(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.tileActive.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      Icons.flash_on,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 30,
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

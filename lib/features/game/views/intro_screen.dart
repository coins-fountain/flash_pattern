import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/core/widgets/banner_ad_widget.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flash_pattern/features/game/controllers/introduce_controller.dart';
import 'package:flash_pattern/features/game/views/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  final controller = Get.put(IntroController());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scale = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  void _startGame() {
    Get.find<GameController>().startGame();
    Get.off(() => const GameScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _demoGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemBuilder: (_, index) {
          return Obx(() {
            final isActive = index == controller.activeIndex.value;
            final isTapped = index == controller.tappedIndex.value;
            final isWrong = controller.isWrong.value;
            final isMemorizing = controller.isMemorizing.value;

            Color tileColor = AppColors.tileInactive;

            if (isWrong) {
              tileColor = Colors.redAccent;
            } else if (isMemorizing && isActive) {
              tileColor = AppColors.tileActive;
            } else if (!isMemorizing && isTapped && isActive) {
              tileColor = AppColors.tileActive;
            } else if (!isMemorizing && isTapped && !isActive) {
              tileColor = Colors.redAccent;
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.transparent,
                onTap: () => controller.handleTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset("assets/icon/icon_flash_pattern.png", height: 100),
                      const SizedBox(height: 20),
                      Obx(() {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: controller.isMemorizing.value ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.isMemorizing.value ? "MEMORIZING..." : "YOUR TURN!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.isMemorizing.value ? Colors.orange : Colors.green,
                              letterSpacing: 1.2,
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 10,),
                      Expanded(child: _demoGrid()),
                      SizedBox(height: 10,),
                      const Text(
                        "Memorize the green tile.\nRepeat the pattern.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      GetX<GameController>(
                        builder: (controller) {
                          return Text(
                            "High Score: ${controller.highScore.value}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.bold),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tileActive,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _startGame,
                          child: const Text(
                            "START",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 60,)
                    ],
                  ),
                ),
              ),
            ),

            const Positioned(bottom: 0, left: 0, right: 0, child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }
}

import 'package:flash_pattern/core/constants/app_colors.dart';
import 'package:flash_pattern/features/game/controllers/ads_controller/consent_controller.dart';
import 'package:flash_pattern/features/game/view/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _isAnimating = true;
  bool highlight = false;

  @override
  void initState() {
    super.initState();
    _initAds();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _startTileAnimation();
    });

  }

  void _startTileAnimation() async {
    while (_isAnimating && mounted) {

      if (!mounted) break;
      setState(() => highlight = true);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!_isAnimating || !mounted) break;
      setState(() => highlight = false);

      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  void _startGame() {
    Get.off(
          () => const GameScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }
  Future<void> _initAds() async {
    final consentController = Get.find<ConsentController>();
    await consentController.initializeConsent();
    await MobileAds.instance.initialize();
  }

  @override
  void dispose() {
    _isAnimating = false;
    _controller.dispose();
    super.dispose();
  }

  Widget _demoGrid() {
    return SizedBox(
      height: 160,
      child: GridView.builder(
        itemCount: 9,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: (index == 4 && highlight)
                  ? AppColors.tileActive
                  : AppColors.tileInactive,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icon/icon_flash_pattern.png",
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  _demoGrid(),
                  const SizedBox(height: 30),
                  const Text(
                    "Memorize the green tile.\nRepeat the pattern.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tileActive,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.tileActive.withOpacity(0.5),
                      ),
                      onPressed: _startGame,
                      child: const Text(
                        "START",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
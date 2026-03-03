import 'dart:math';
import 'package:get/get.dart';

class IntroController extends GetxController {
  final activeIndex = 0.obs;
  final tappedIndex = Rxn<int>();

  final isMemorizing = true.obs;
  final isWrong = false.obs;
  final isProcessingTap = false.obs;

  @override
  void onInit() {
    super.onInit();
    startDemoRound();
  }

  Future<void> startDemoRound() async {
    isMemorizing.value = true;
    isWrong.value = false;
    tappedIndex.value = null;

    activeIndex.value = Random().nextInt(4);

    await Future.delayed(const Duration(seconds: 1));
    isMemorizing.value = false;
  }

  Future<void> handleTap(int index) async {
    if (isMemorizing.value || isProcessingTap.value) return;

    isProcessingTap.value = true;
    tappedIndex.value = index;
    await Future.delayed(const Duration(milliseconds: 250));

    if (index == activeIndex.value) {
      tappedIndex.value = null;

      await Future.delayed(const Duration(milliseconds: 200));
      await startDemoRound();
    } else {
      isWrong.value = true;

      await Future.delayed(const Duration(milliseconds: 500));
      await startDemoRound();
    }

    isProcessingTap.value = false;
  }
}

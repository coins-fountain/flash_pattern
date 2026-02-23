import 'package:flash_pattern/features/game/view/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/game/bindings/game_bindings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GameBinding(),
      home: const IntroScreen(),
    );
  }
}
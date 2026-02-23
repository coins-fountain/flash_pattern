import 'package:flash_pattern/features/game/views/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'features/game/bindings/game_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run the app first so the user sees the UI immediately.
  runApp(const MyApp());

  // Initialize background services (Consent & Ads) via GameBinding/AdService
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

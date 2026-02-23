import 'package:flash_pattern/features/game/controllers/ads_controller/consent_controller.dart';
import 'package:flash_pattern/features/game/view/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'features/game/bindings/game_bindings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final consentController =
  Get.put(ConsentController(), permanent: true);

  await consentController.initializeConsent();

  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      testDeviceIds: [],
    ),
  );

  await MobileAds.instance.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
import 'package:flash_pattern/core/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AdService>(
      builder: (controller) {
        final ad = controller.bannerAd;
        if (controller.isBannerAdLoaded.value && ad != null) {
          return Container(
            alignment: Alignment.center,
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

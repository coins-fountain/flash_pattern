import 'dart:io';
import 'package:flash_pattern/features/game/controllers/ads_controller/consent_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  BannerAd? bannerAd;
  var isBannerAdLoaded = false.obs;
  final ConsentController _consentController = Get.find<ConsentController>();

  AdRequest get _adRequest =>
      AdRequest(nonPersonalizedAds: !_consentController.isConsentGiven.value);

  InterstitialAd? interstitialAd;
  var isInterstitialAdLoaded = false.obs;

  RewardedAd? rewardedAd;
  var isRewardedAdLoaded = false.obs;

  DateTime? _lastInterstitialShown;
  final Duration _interstitialCooldown = const Duration(seconds: 75);

  bool get _canShowInterstitial {
    if (_lastInterstitialShown == null) return true;

    final diff = DateTime.now().difference(_lastInterstitialShown!);
    return diff >= _interstitialCooldown;
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialAds();

    ever(_consentController.isConsentGiven, (bool value) {
      reloadAllAds();
    });
  }

  void _loadInitialAds() {
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void reloadAllAds() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();

    isBannerAdLoaded.value = false;
    isInterstitialAdLoaded.value = false;
    isRewardedAdLoaded.value = false;

    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
    super.onClose();
  }

  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
      ),
    );
    bannerAd!.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialAdLoaded.value = true;

          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          isRewardedAdLoaded.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      interstitialAd!.show();
      interstitialAd = null;
      isInterstitialAdLoaded.value = false;
    }
  }

  void showRewardedAd({required void Function() onRewardEarned}) {
    if (rewardedAd == null || !isRewardedAdLoaded.value) return;

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );

    rewardedAd = null;
    isRewardedAdLoaded.value = false;
  }

  void showInterstitial({void Function()? onClosed}) {
    // Jika dalam masa cooldown (75 detik), langsung lanjut tanpa iklan
    if (!_canShowInterstitial) {
      onClosed?.call();
      return;
    }

    // Jika iklan sudah ready, langsung tampilkan
    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      _showActualAd(onClosed);
    } else {
      // Jika iklan BELUM ready, kita tunggu sebentar pakai Loading Overlay
      _waitForAdThenShow(onClosed);
    }
  }

  // Fungsi pembantu untuk menampilkan iklan yang sudah siap
  void _showActualAd(void Function()? onClosed) {
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitialShown = DateTime.now();
        ad.dispose();
        _loadInterstitialAd(); // Preload iklan berikutnya
        onClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
        onClosed?.call();
      },
    );

    interstitialAd!.show();
    interstitialAd = null;
    isInterstitialAdLoaded.value = false;
  }

  Future<void> _waitForAdThenShow(void Function()? onClosed) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.green)),
      barrierDismissible: false,
    );
    _loadInterstitialAd();
    int attempts = 0;
    while (interstitialAd == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    // Close the loading dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      _showActualAd(onClosed);
    } else {
      print("Iklan tidak tersedia setelah ditunggu, lanjut game...");
      onClosed?.call();
    }
  }
}

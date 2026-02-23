import 'package:flash_pattern/core/services/consent_service.dart';
import 'package:flash_pattern/core/utils/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends GetxService {
  BannerAd? bannerAd;
  var isBannerAdLoaded = false.obs;
  final ConsentService _consentService = Get.find<ConsentService>();

  AdRequest get _adRequest =>
      AdRequest(nonPersonalizedAds: !_consentService.isConsentGiven.value);

  InterstitialAd? interstitialAd;
  var isInterstitialAdLoaded = false.obs;
  bool isInterstitialLoading = false; // Add this to prevent redundant loads

  RewardedAd? rewardedAd;
  var isRewardedAdLoaded = false.obs;

  DateTime? _lastInterstitialShown;
  final Duration _interstitialCooldown = const Duration(minutes: 1);

  bool get _canShowInterstitial {
    if (_lastInterstitialShown == null) return true;

    final diff = DateTime.now().difference(_lastInterstitialShown!);
    return diff >= _interstitialCooldown;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeAndLoad();

    ever(_consentService.isConsentGiven, (bool value) {
      reloadAllAds();
    });
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _consentService.initializeConsent();

      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          testDeviceIds: [],
        ),
      );

      await MobileAds.instance.initialize();
      _loadInitialAds();
    } catch (e) {
      debugPrint("Error during AdService initialization: $e");
    }
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
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner Ad failed to load: ${error.message}");
          ad.dispose();
          isBannerAdLoaded.value = false;
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
      ),
    );
    bannerAd!.load();
  }

  void _loadInterstitialAd() {
    if (isInterstitialLoading) return;

    isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialAdLoaded.value = true;
          isInterstitialLoading = false;

          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("Interstitial Ad failed to show: ${error.message}");
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint("Interstitial Ad failed to load: ${error.message}");
          isInterstitialAdLoaded.value = false;
          isInterstitialLoading = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint("Rewarded Ad failed to load: ${error.message}");
          isRewardedAdLoaded.value = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  void showInterstitial({void Function()? onClosed}) {
    if (!_canShowInterstitial) {
      onClosed?.call();
      return;
    }

    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      _showActualAd(onClosed);
    } else {
      _waitForAdThenShow(onClosed);
    }
  }

  void _showActualAd(void Function()? onClosed) {
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitialShown = DateTime.now();
        ad.dispose();
        _loadInterstitialAd();
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

    _loadInterstitialAd(); // Will return early if already loading

    int attempts = 0;
    // Wait up to 5 seconds
    while (interstitialAd == null && attempts < 25) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (interstitialAd != null && isInterstitialAdLoaded.value) {
      _showActualAd(onClosed);
    } else {
      onClosed?.call();
    }
  }

  void showRewardedAd({
    required void Function() onRewardEarned,
    void Function()? onAdDismissed,
    void Function()? onAdFailed,
  }) {
    if (rewardedAd == null || !isRewardedAdLoaded.value) {
      onAdFailed?.call();
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        onAdFailed?.call();
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
}

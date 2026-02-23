import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class ConsentService extends GetxService {
  var isConsentGiven = false.obs;
  var isConsentRequired = false.obs;
  var isRequestLocationInEeaOrUk = false.obs;

  Future<void> initializeConsent() async {
    final completer = Completer<void>();

    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        final status = await ConsentInformation.instance.getConsentStatus();

        isConsentGiven.value = status == ConsentStatus.obtained;
        isConsentRequired.value = status == ConsentStatus.required;

        final inEeaOrUk = await ConsentInformation.instance
            .isConsentFormAvailable();
        isRequestLocationInEeaOrUk.value = inEeaOrUk;

        if (!completer.isCompleted) completer.complete();
      },
      (FormError error) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> showConsentFlow() async {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      isConsentGiven.value = status == ConsentStatus.obtained;
      isConsentRequired.value = status == ConsentStatus.required;

      completer.complete();
    });

    return completer.future;
  }

  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();

    ConsentForm.showPrivacyOptionsForm((FormError? error) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      isConsentGiven.value = status == ConsentStatus.obtained;

      completer.complete();
    });

    return completer.future;
  }
}

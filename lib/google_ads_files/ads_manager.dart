import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';

//This class is for global tracking when on back is pressed
class AdsManager {
  static int _backPressed = 0;
  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAds() {
    AdsHelper.loadInterstitialAds(onLoaded: (ads) {
      _interstitialAd = ads;
    }, OnError: (error) {
      print('Intertitial Ad is not loaded ${error}');
    });
  }

  static void handelBackPress() {
    _backPressed++;

    if (_backPressed >= 3) {
      if (_interstitialAd != null) {
        _interstitialAd?.show();
        _interstitialAd = null;
        loadInterstitialAds();
      }
      _backPressed = 0;
    }
  }
}

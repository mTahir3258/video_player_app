import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static BannerAd? bannerAd;

  static BannerAd? loadBannerAds({required VoidCallback onAdLoaded}) {
    if (!(Platform.isAndroid || Platform.isIOS)) return null;

    bannerAd = BannerAd(
      size: AdSize.banner,

      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',

      //*********************************  Using Real Ad Unit IDs *****************************************

      // ? "ca-app-pub-3836573422628323/4794163967"
      // :"ca-app-pub-3836573422628323/1127650613",

      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner Loaded :- Success');
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('Ads Error is ${error}');
          ad.dispose();
        },
      ),
      request: AdRequest(),
    );

    bannerAd?.load();

    return bannerAd;
  }

  static void loadInterstitialAds(
      {required Function(InterstitialAd) onLoaded,
      required Function(LoadAdError) OnError}) {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910',

      //*****   Using Real Ads Unit Id */

      // ? 'ca-app-pub-3836573422628323/1173658748'
      // : 'ca-app-pub-3836573422628323/7460689906',

      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          OnError(error);
        },
      ),

      request: AdRequest(),
    );
  }
}

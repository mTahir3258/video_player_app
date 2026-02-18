import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';

class AdsWidget extends StatefulWidget {
  const AdsWidget({super.key});

  @override
  State<AdsWidget> createState() => _AdsWidgetState();
}

class _AdsWidgetState extends State<AdsWidget> {
  BannerAd? bannerAd; //store the ads
  InterstitialAd? _interstitialAd;
  bool _isLoading = false; //track the widget is ready for ads

  @override
  void initState() {
    super.initState();

    //banner ads
    bannerAd = AdsHelper.loadBannerAds(
      onAdLoaded: () {
      print('Banner Loaded');
      setState(() {
        _isLoading = true;
      });
    });
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ads Widget',
          style: TextStyle(
              fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (bannerAd != null && _isLoading)
            Center(
              child: Container(
                alignment: Alignment.center,
                height: bannerAd!.size.height.toDouble(),
                width: bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}

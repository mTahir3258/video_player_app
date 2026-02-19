// comment: import Flutter UI
import 'package:flutter/material.dart';

// comment: import Google Ads
import 'package:google_mobile_ads/google_mobile_ads.dart';

// comment: import Ads helper
import 'package:player_app/google_ads_files/ads_helper.dart';

// comment: ads screen widget
class AdsWidget extends StatefulWidget {
  const AdsWidget({super.key});

  @override
  State<AdsWidget> createState() => _AdsWidgetState();
}

// comment: state class
class _AdsWidgetState extends State<AdsWidget> {

  // comment: store banner ad
  BannerAd? bannerAd;

  // comment: optional interstitial ad
  InterstitialAd? _interstitialAd;

  // comment: track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // comment: load banner ad
    bannerAd = AdsHelper.loadBannerAds(
      onAdLoaded: () {
        // comment: check widget still active
        if (!mounted) return;

        // comment: update UI
        setState(() {
          _isLoading = true;
        });

        debugPrint('✅ Banner Loaded');
      },
    );
  }

  @override
  void dispose() {
    // comment: dispose banner ad
    bannerAd?.dispose();

    // comment: dispose interstitial ad if used
    _interstitialAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // comment: get screen info
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;

    // comment: responsive padding
    final padding = shortestSide * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      // comment: top app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Ads Widget',
          // comment: responsive text size
          style: TextStyle(
            fontSize: shortestSide * 0.04,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // comment: body
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(padding),

          child: bannerAd != null && _isLoading
              ? Container(
                  // comment: banner container
                  alignment: Alignment.center,
                  height: bannerAd!.size.height.toDouble(),
                  width: bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd!),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // comment: loading indicator
                    const CircularProgressIndicator(),

                    SizedBox(height: padding),

                    // comment: loading text
                    Text(
                      "Loading Ad...",
                      style: TextStyle(
                        fontSize: shortestSide * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

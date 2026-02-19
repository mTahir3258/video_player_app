// comment: import Flutter UI package
import 'package:flutter/material.dart';

// comment: import Google Mobile Ads
import 'package:google_mobile_ads/google_mobile_ads.dart';

// comment: import your ads helper
import 'package:player_app/google_ads_files/ads_helper.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {

  // comment: variable to store interstitial ad
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    // comment: load full screen ad when screen opens
    fullScreenAds();
  }

  // comment: function to load and show ad
  void fullScreenAds() {
    AdsHelper.loadInterstitialAds(

      // comment: when ad loaded
      onLoaded: (ads) {
        _interstitialAd = ads;
        _interstitialAd?.show();
      },

      // comment: when ad fails
      OnError: (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ads not loaded'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // comment: dispose ad to free RAM
    _interstitialAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // comment: get screen size
    final media = MediaQuery.of(context);

    // comment: responsive base size
    final shortestSide = media.size.shortestSide;

    // comment: responsive sizes
    final iconSize = shortestSide * 0.06;
    final titleFont = shortestSide * 0.05;
    final bodyFont = shortestSide * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      // comment: top app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // comment: back button
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: iconSize,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        // comment: screen title
        title: Text(
          'Download Screen',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // comment: screen body
      body: Center(
        child: Text(
          'Download Screen',
          style: TextStyle(
            fontSize: bodyFont,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// comment: import packages
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  // comment: interstitial ad variable
  InterstitialAd? _interstitialAd;

  // comment: load and show full screen ad
  void fullScreenAds() {
    AdsHelper.loadInterstitialAds(
      onLoaded: (ads) {
        _interstitialAd = ads;

        // comment: show ad when loaded
        _interstitialAd?.show();

        if (mounted) {
          setState(() {}); // comment: refresh UI if needed
        }
      },
      OnError: (error) {
        // comment: show error message if ad fails
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Full Screen ads not loaded'),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // comment: show ad when screen opens
    fullScreenAds();
  }

  @override
  void dispose() {
    // comment: dispose ad to free RAM
    _interstitialAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // comment: get responsive base size
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

        // comment: title text
        title: Text(
          'Videos Screen',
          style: TextStyle(
            fontSize: titleFont,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      // comment: body content
      body: Center(
        child: Text(
          'Videos Screen',
          style: TextStyle(
            fontSize: bodyFont,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

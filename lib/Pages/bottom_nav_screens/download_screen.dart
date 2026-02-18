import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    fullScreenAds();
  }

  //function for full screen ads
  void fullScreenAds() {
    AdsHelper.loadInterstitialAds(onLoaded: (ads) {
      _interstitialAd = ads;
      _interstitialAd?.show();
    }, OnError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ads not loaded Successfully',
            style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w600),
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final shortestSide = media.size.shortestSide;
    final iconSize = shortestSide * 0.06;
    //font size dof title
    final titleFont = shortestSide * 0.05;
    //font body size
    final bodyFont = shortestSide * 0.04;
    //basic layout structure scaffold
    return Scaffold(
      //appbar
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        title: Text(
          'Download Screen',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'Download Screen',
          style: TextStyle(fontSize: bodyFont, color: Colors.white),
        ),
      ),
    );
  }
}

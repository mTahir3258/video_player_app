import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  InterstitialAd? _interstitialAd;

  void fullScreenAds() {
    AdsHelper.loadInterstitialAds(onLoaded: (ads) {
      _interstitialAd = ads;
      _interstitialAd?.show();
      setState(() {});
    }, OnError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Full Screen ads not loaded',
        style: TextStyle(
            fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w500),
      )));
    });
  }

  @override
  void initState() {
    super.initState();
    fullScreenAds();
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

//basic layout structure
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      //Top App bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            )),
        title: Text(
          'Videos Screen',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      //Body of the screen
      body: Center(
        child: Text(
          'Videos Screen',
          style: TextStyle(fontSize: bodyFont, color: Colors.white),
        ),
      ),
    );
  }
}

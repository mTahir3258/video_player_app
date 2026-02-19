// comment: import needed packages
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:video_player/video_player.dart';

class FatafatScreen extends StatefulWidget {
  const FatafatScreen({super.key});

  @override
  State<FatafatScreen> createState() => _FatafatScreenState();
}

class _FatafatScreenState extends State<FatafatScreen> {
  // comment: page controllers for vertical video feeds
  late PageController _homePageController;
  late PageController _forYouPageController;

  // comment: interstitial ad variable
  InterstitialAd? _interstitialAd;

  // comment: list of video URLs
  final List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
  ].map((url) => url.trim()).toList();

  // comment: separate video controllers per tab
  final Map<String, Map<int, VideoPlayerController>> _allControllers = {
    'home': {},
    'forYou': {},
  };

  // comment: current playing index
  int _homeIndex = 0;
  int _forYouIndex = 0;

  @override
  void initState() {
    super.initState();

    // comment: initialize page controllers
    _homePageController = PageController();
    _forYouPageController = PageController();

    // comment: load full screen ad
    fullScreenAds();

    // comment: initialize first video after UI build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo('home', 0);
    });
  }

  // comment: load and show interstitial ad
  void fullScreenAds() {
    AdsHelper.loadInterstitialAds(
      onLoaded: (ads) {
        _interstitialAd = ads;
        _interstitialAd?.show();

        if (mounted) {
          setState(() {}); // comment: refresh UI if needed
        }
      },
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

  // comment: initialize video safely
  Future<void> _initializeVideo(String tab, int index) async {
    final controllers = _allControllers[tab]!;

    // comment: skip if already loaded
    if (controllers.containsKey(index)) return;

    // comment: create video controller
    final controller = VideoPlayerController.network(
      videoUrls[index],
    )..setLooping(true);

    try {
      // comment: store controller before initialize
      controllers[index] = controller;

      await controller.initialize();

      if (!mounted) return;

      // comment: play only active video
      final isActive = (tab == 'home' && index == _homeIndex) ||
          (tab == 'forYou' && index == _forYouIndex);

      if (isActive) {
        await controller.play();
      }

      setState(() {}); // comment: update UI
    } catch (e) {
      // comment: remove broken controller
      controllers.remove(index);
      controller.dispose();
    }
  }

  // comment: manage play/pause
  void _managePlayback(String tab, int activeIndex) {
    final controllers = _allControllers[tab]!;

    controllers.forEach((index, controller) {
      if (index == activeIndex &&
          controller.value.isInitialized &&
          !controller.value.isPlaying) {
        controller.play();
      } else if (index != activeIndex && controller.value.isPlaying) {
        controller.pause();
      }
    });
  }

  @override
  void dispose() {
    // comment: dispose ads
    _interstitialAd?.dispose();

    // comment: dispose all video controllers
    for (var tabControllers in _allControllers.values) {
      for (var controller in tabControllers.values) {
        controller.dispose();
      }
    }

    // comment: dispose page controllers
    _homePageController.dispose();
    _forYouPageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // comment: responsive base size
    final shortestSide = media.size.shortestSide;

    // comment: responsive sizes
    final iconSize = shortestSide * 0.06;
    final titleFont = shortestSide * 0.05;
    final bodyFont = shortestSide * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      // comment: top bar
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

        // comment: title
        title: Text(
          'Live Videos',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // comment: body placeholder
      body: Center(
        child: Text(
          'Live Videos',
          style: TextStyle(
            fontSize: bodyFont,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

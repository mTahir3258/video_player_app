import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:player_app/Pages/bottom_nav_screens/bottom_nav_home.dart';
import 'package:player_app/Pages/list_of_videos.dart';
import 'package:player_app/Pages/screens/page_view_task.dart';
import 'package:player_app/Pages/splash_screen.dart';
import 'package:player_app/firebase_options.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:player_app/google_ads_files/ads_widget.dart';
import 'package:player_app/model/system_video_model.dart';
import 'package:player_app/model/video_playList.dart';
import 'package:player_app/state/playlist_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//========= Banner Ads =======================

//Ad Mob App Id For Android  for banner ads
//ca-app-pub-3836573422628323~1123781187

//Add Mob Unit Id for Android for banner ads
//ca-app-pub-3836573422628323/4794163967

//=============== for IOS ==================

//Ad Mob App Id  for IOS for banner ads
//ca-app-pub-3836573422628323~5196664234

//Ad Mob Unit Id for IOS banner ads
//ca-app-pub-3836573422628323/1127650613

// ================= Interertitial Ads ====================

//Add Mob App Id for Android for Interestitial ads
//ca-app-pub-3836573422628323~1123781187

//Add Mob Unit Id for Android for Interestitial ads
//ca-app-pub-3836573422628323/1173658748

//Add Mob App Id for Ios for Interestitial Ads
//ca-app-pub-3836573422628323~5196664234

//Add Mob App Id for Ios for Interestitial Ads
//ca-app-pub-3836573422628323/7460689906

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  MediaKit.ensureInitialized();
  await Supabase.initialize(
      url: 'https://kdqcmzpcsnwntsetwynz.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkcWNtenBjc253bnRzZXR3eW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MjY0MDgsImV4cCI6MjA4NjIwMjQwOH0.5Le6jJtv56FzH0V5VzovK8TSKJcuj24edCzQtGltPRg');

  await Hive.initFlutter();
  Hive.registerAdapter(SystemVideoAdapter());
  Hive.registerAdapter(VideoPlaylistAdapter());

  await Hive.openBox<VideoPlaylist>('playlistBox');

  AdsManager.loadInterstitialAds();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playlistNotifier,
      builder: (context, List<VideoPlaylist> playlist, _) => MaterialApp(
        debugShowCheckedModeBanner: false,

        home: SplashScreen(),
        //=== Googel ads Test Screen
        // home: AdsWidget(),
      ),
    );
  }
}

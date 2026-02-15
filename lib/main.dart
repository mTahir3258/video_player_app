import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:player_app/Pages/bottom_nav_screens/bottom_nav_home.dart';
import 'package:player_app/Pages/list_of_videos.dart';
import 'package:player_app/Pages/screens/page_view_task.dart';
import 'package:player_app/Pages/splash_screen.dart';
import 'package:player_app/firebase_options.dart';
import 'package:player_app/model/system_video_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Supabase.initialize(
      url: 'https://kdqcmzpcsnwntsetwynz.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkcWNtenBjc253bnRzZXR3eW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MjY0MDgsImV4cCI6MjA4NjIwMjQwOH0.5Le6jJtv56FzH0V5VzovK8TSKJcuj24edCzQtGltPRg');

  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: SplashScreen(),
      home: SplashScreen(),
    );
  }
}

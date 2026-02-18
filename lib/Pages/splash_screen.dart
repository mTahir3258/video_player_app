import 'dart:async';
import 'package:flutter/material.dart';
import 'package:player_app/Pages/bottom_nav_screens/bottom_nav_home.dart';
import 'package:player_app/Pages/screens/page_view_task.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //Delay for 3 second
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PageViewTask()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16A34A), // Primary Green
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF16A34A).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  
        ),
                  child: const Icon(
                    Icons.play_arrow_rounded, // Matches the white play button
                    color: Colors.white,
                    size: 60,
                  ),
                ),
      


            // Container(
            //   height: screenHeight * 0.3,
            //   width: screenWidth  *0.3,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     image: DecorationImage(
            //       image: AssetImage('assets/images/video_icon.png'),
            //     ),
            //   ),
            // ),

            const SizedBox(
              height: 25.0,
            ),
            Text(
              'Cubo Player',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),
            Text('premium media experiance'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 2.5

            ),)
          ],
        ),
      ),
    );
  }
}

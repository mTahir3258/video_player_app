import 'dart:async';
import 'package:flutter/material.dart';
import 'package:player_app/Pages/screens/page_view_task.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Timer? _timer; // ✅ Store timer so we can cancel it later

  @override
  void initState() {
    super.initState();

    // ✅ Start splash delay
    _timer = Timer(const Duration(seconds: 5), () {

      // ✅ Check if widget still exists before navigating
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PageViewTask(),
        ),
      );
    });
  }

  @override
  void dispose() {
    // ✅ Cancel timer to prevent memory leak
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context);
    final size = media.size;

    // ✅ Use shortestSide for better scaling on all devices
    final base = size.shortestSide;

    final logoSize = base * 0.32;     // Responsive logo size
    final iconSize = base * 0.16;     // Responsive icon size
    final titleSize = base * 0.075;   // Responsive title
    final subtitleSize = base * 0.032;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ✅ App Logo
            Container(
              height: logoSize,
              width: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A),

                // ✅ Soft glowing shadow
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.4),
                    blurRadius: logoSize * 0.35,
                    spreadRadius: logoSize * 0.08,
                  ),
                ],
              ),

              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ),

            SizedBox(height: base * 0.06),

            // ✅ App Name
            Text(
              'Cubo Player',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: base * 0.02),

            // ✅ Subtitle
            Text(
              'PREMIUM MEDIA EXPERIENCE',
              style: TextStyle(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

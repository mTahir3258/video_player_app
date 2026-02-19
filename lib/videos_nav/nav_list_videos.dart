import 'package:flutter/material.dart';

class NavListVideos extends StatefulWidget {
  const NavListVideos({super.key});

  @override
  State<NavListVideos> createState() => _NavListVideosState();
}

class _NavListVideosState extends State<NavListVideos> {

  // ✅ Image list
  final List<String> images = [
    'assets/images/images_1.jpg',
    'assets/images/images_2.jpg',
    'assets/images/images_3.jpg',
    'assets/images/images_4.jpg',
    'assets/images/images_5.png',
    'assets/images/images_6.png',
  ];

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context);
    final size = media.size;

    // ✅ Base unit for responsiveness
    final base = size.shortestSide;

    final itemHeight = base * 0.45;     // Responsive card height
    final borderRadius = base * 0.04;   // Responsive radius
    final padding = base * 0.03;        // Responsive spacing

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(padding),

          itemCount: images.length, // ✅ Prevent crash

          itemBuilder: (context, index) {
            return Container(
              height: itemHeight,
              margin: EdgeInsets.only(bottom: padding),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),

                border: Border.all(
                  width: 1.2,
                  color: Colors.white.withOpacity(0.2),
                ),

                image: DecorationImage(
                  image: AssetImage(images[index]),

                  fit: BoxFit.cover, // ✅ Prevent distortion
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ✅ Nothing heavy to dispose here,
    // but keeping dispose for future additions
    super.dispose();
  }
}

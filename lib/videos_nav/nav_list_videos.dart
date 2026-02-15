import 'package:flutter/material.dart';

class NavListVideos extends StatefulWidget {
  const NavListVideos({super.key});

  @override
  State<NavListVideos> createState() => _NavListVideosState();
}

class _NavListVideosState extends State<NavListVideos> {
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
    return Scaffold(
      body: Column(
        children: [
          ListView.builder(itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(width: 1.0, color: Colors.black),
                  image: DecorationImage(image: AssetImage(images[index]))),
            );
          }),
        ],
      ),
    );
  }
}

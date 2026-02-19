// comment: import Flutter UI
import 'package:flutter/material.dart';

// comment: import all screens
import 'package:player_app/Pages/bottom_nav_screens/download_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/fatafat_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/serch_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/videos_screen.dart';
import 'package:player_app/Pages/videos_Folder.dart';

// comment: main bottom navigation widget
class BottomNavHome extends StatefulWidget {
  const BottomNavHome({super.key});

  @override
  State<BottomNavHome> createState() => _BottomNavHomeState();
}

// comment: state class
class _BottomNavHomeState extends State<BottomNavHome> {

  // comment: store selected tab index
  int _currentIndex = 0;

  // comment: list of screens
  final List<Widget> _screenList = [
    VideosFolder(),
    VideosScreen(),
    FatafatScreen(),
    SearchScreen(),
    DownloadScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    // comment: get screen info
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    final width = media.size.width;

    // comment: responsive sizes
    final navHeight = shortestSide * 0.12;
    final iconSize = shortestSide * 0.065;
    final paddingHorizontal = width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      // comment: show selected screen
      body: IndexedStack(
        index: _currentIndex,
        children: _screenList,
      ),

      // comment: custom bottom navigation bar
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          paddingHorizontal,
          0,
          paddingHorizontal,
          shortestSide * 0.03,
        ),
        child: Container(
          height: navHeight,

          // comment: nav bar design
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(navHeight),
            color: const Color(0xFF0D1117).withOpacity(0.9),
            border: Border.all(width: 1.0, color: Colors.white12),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              navItem(Icons.folder, 0, iconSize),
              navItem(Icons.play_circle_outline, 1, iconSize),
              navItem(Icons.smartphone, 2, iconSize),
              navItem(Icons.search, 3, iconSize),
              navItem(Icons.cloud_download_outlined, 4, iconSize),
            ],
          ),
        ),
      ),
    );
  }

  // comment: bottom nav item widget
  Widget navItem(IconData icon, int index, double iconSize) {

    // comment: check active tab
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        // comment: change tab
        setState(() {
          _currentIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        // comment: responsive padding
        padding: EdgeInsets.all(iconSize * 0.35),

        // comment: active glow effect
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF22C55E)
              : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.4),
                    blurRadius: iconSize * 0.6,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),

        // comment: icon
        child: Icon(
          icon,
          size: iconSize,
          color: isActive ? Colors.white : Colors.white54,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // comment: nothing heavy to dispose here
    super.dispose();
  }
}

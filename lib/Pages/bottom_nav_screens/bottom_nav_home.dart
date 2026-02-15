import 'package:flutter/material.dart';
import 'package:player_app/Pages/bottom_nav_screens/download_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/fatafat_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/serch_screen.dart';
import 'package:player_app/Pages/bottom_nav_screens/videos_screen.dart';
import 'package:player_app/Pages/videos_Folder.dart';

// Main widget for bottom navigation home screen
class BottomNavHome extends StatefulWidget {
  const BottomNavHome({super.key});

  @override
  State<BottomNavHome> createState() => _BottomNavHomeState();
}

// State class for BottomNavHome
class _BottomNavHomeState extends State<BottomNavHome> {
  // Stores the currently selected bottom navigation index
  int _currentIndex = 0;

  // List of screens shown when bottom navigation item is selected
  final List<Widget> _screenList = [
    VideosFolder(),
    VideosScreen(),
    FatafatScreen(),
    SearchScreen(),
    DownloadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen size information
    final media = MediaQuery.of(context);
    // Get the shortest side of the screen
    final shortestSide = media.size.shortestSide;
    // Set icon size based on screen size
    final iconSize = shortestSide * 0.06;

    return Scaffold(
        // Show the selected screen based on current index
        backgroundColor: Color(0xFF0D1117),
        body: _screenList[_currentIndex],
        // Bottom navigation bar
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
          child: Container(
            height: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              color: Color(0xFF0D1117).withOpacity(0.9),
              border: Border.all(width: 1.0, color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  navItem(Icons.folder, 0),
                  navItem(Icons.play_circle_outline, 1),
                  navItem(Icons.smartphone, 2),
                  navItem(Icons.search, 3),
                  navItem(Icons.cloud_download_outlined, 4),
                ],
              ),
            ),
          ),
        ));
  }

  Widget navItem(IconData icon, int index) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          //Active Item with green glow
          color: isActive ? const Color(0xFF22C55E):Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
           ?
           [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2
            ),

          ]
          :[],
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.white : Colors.white54,
          ),
        )
    );
  }
}

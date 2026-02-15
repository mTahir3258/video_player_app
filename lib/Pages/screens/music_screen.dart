import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //retrievign the screen size
    final media = MediaQuery.of(context);
    //retrieving the width of the screen
    final width = media.size.width;
    //retrieving the shortest side of the  screen
    final shortestSide = media.size.shortestSide;
    //set the title font
    final titleFont = shortestSide * 0.05;
    //set the body ont
    final bodyFont = shortestSide * 0.04;
    //set the icon size
    final iconSize = shortestSide * 0.07;

//basic layout structure
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
        ),
        title: Text(
          'Music Screen',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.white,
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'Music Screen',
          style: TextStyle(
            fontSize: bodyFont,
          ),
        ),
      ),
    );
  }
}

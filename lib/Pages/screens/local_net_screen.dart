import 'package:flutter/material.dart';

class LocalNetScreen extends StatelessWidget {
  const LocalNetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //retrieving the screen size
    final media = MediaQuery.of(context);
    //retrieving the width of the screen
    final width = media.size.width;
    //set the shortest side
    final shortestSide = media.size.shortestSide;
    //set the title font
    final titleFont = shortestSide * 0.05;
    //set the body font
    final bodyFont = shortestSide * 0.04;
    //set the icon size
    final iconSize = shortestSide * 0.07;

//Basic layout structure
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
          'Local Network Screen',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.white,
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'Local Network Screen',
          style: TextStyle(
            fontSize: bodyFont,
          ),
        ),
      ),
    );
  }
}

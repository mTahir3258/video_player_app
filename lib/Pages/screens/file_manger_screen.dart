import 'package:flutter/material.dart';

class FileMangerScreen extends StatelessWidget {
  const FileMangerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //retrieving the screen size
    final media = MediaQuery.of(context);
    //retrieving the width of screen
    final width = media.size.width;
    //retrieving the shortest side
    final shortestSide = media.size.shortestSide;
    //Set the title font size
    final titleFont = shortestSide * 0.05;
    //set the body font size
    final bodyFont = shortestSide * 0.04;
    //setting up the icon size 
    final iconSize = shortestSide * 0.07;

//basic layout structure
    return Scaffold(
      //top app bar 
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
        ),
        title: Text(
          'File Manager',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.black,
          ),
        ),
      ),

      //body of the screen
      body: Center(
        child: Text(
          'File Manager Screen',
          style: TextStyle(
            fontSize: bodyFont,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FileTransfer extends StatelessWidget {
  const FileTransfer({super.key});

  @override
  Widget build(BuildContext context) {
    //retrieving the screen size
    final media = MediaQuery.of(context);
    //retiriving the with of the screen
    final width = media.size.width;
    //shortest side of the screen
    final shortestSide = media.size.shortestSide;
    //title font size set
    final titleFont = shortestSide * 0.05;
    //body font size set
    final bodyFont = shortestSide * 0.04;
    //iconsize set
    final iconSize = shortestSide * 0.07;

//basic layout structure
    return Scaffold(
      //top app bar of the app
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
        ),
        title: Text(
          'File Transfer Screen',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.black,
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'File Transfer Screen',
          style: TextStyle(
            fontSize: bodyFont,
          ),
        ),
      ),
    );
  }
}

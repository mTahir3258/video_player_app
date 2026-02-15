import 'package:flutter/material.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
      final media = MediaQuery.of(context);
    final width = media.size.width;
    final shortestSide = media.size.shortestSide;
    final iconSize = shortestSide * 0.06;
    //font size dof title
    final titleFont = shortestSide * 0.05;
    //font body size
    final bodyFont = shortestSide * 0.04;
    //basic layout structure scaffold
    return Scaffold(
      //appbar
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        leading: Icon(Icons.arrow_back_ios_new , color: Colors.white,size: 20,),
        title: Text(
          'Download Screen',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'Download Screen',
          style: TextStyle(
            fontSize: bodyFont,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

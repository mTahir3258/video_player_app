import 'package:flutter/material.dart';

class StreamScreen extends StatelessWidget {
  const StreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final shortestSide = media.size.shortestSide;
    final titleFont = shortestSide * 0.05;
    final bodyFont = shortestSide * 0.04;
    final iconSize = shortestSide * 0.07;

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
          'Stream Screen',
          style: TextStyle(
            fontSize: titleFont,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Stream Screen',
          style: TextStyle(
            fontSize: bodyFont,
          ),
        ),
      ),
    );
  }
}

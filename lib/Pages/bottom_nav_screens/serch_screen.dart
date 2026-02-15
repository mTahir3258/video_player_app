import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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

//basic layout structure
    return Scaffold(

      backgroundColor: Color(0xFF0D1117),
      //top app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios_new,color: Colors.white,size: 20,),
        title: Text(
          'Search Screen',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      //body of the screen
      body: Center(
        child: Text(
          'Search Screen',
          style: TextStyle(
            fontSize: bodyFont,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

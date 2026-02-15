// Import necessary packages for Flutter UI and smooth page indicator

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:player_app/Pages/bottom_nav_screens/bottom_nav_home.dart';
import 'package:player_app/core/constants/app_colors.dart';
import 'package:story_view/story_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageViewTask extends StatefulWidget {
  const PageViewTask({super.key});

  @override
  State<PageViewTask> createState() => _PageViewTaskState();
}

class _PageViewTaskState extends State<PageViewTask> {
  final storyController = StoryController();
  final supabase = Supabase.instance.client;
  List<String> imageURls = [];
  bool isLoading = true;

  Future<void> loadImages() async {
    try {
      //List file names in the bucket
      final List<FileObject> files =
          await supabase.storage.from('banner').list(path: 'banner');

      final urls = files.map((file) {
        return supabase.storage
            .from('banner')
            .getPublicUrl('banner/${file.name}');
      }).toList();
      setState(() {
        imageURls = urls;
        isLoading = false;
      });
    } catch (e) {
      print('Catch the error $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  @override
  void dispose() {
    super.dispose();
    storyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItem = imageURls.map(
      (path) {
        return StoryItem.inlineImage(url: path, controller: storyController);
      },
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color:Color(0xFF22C55E) ,))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StoryView(
                      storyItems: storyItem,
                      controller: storyController,
                      onComplete: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavHome()));
                      },
                      onVerticalSwipeComplete: (direction) {
                        if (direction == Direction.down) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

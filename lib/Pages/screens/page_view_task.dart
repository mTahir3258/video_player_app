// comment: import required packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:player_app/Pages/videos_Folder.dart';
import 'package:player_app/core/constants/app_colors.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:story_view/story_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageViewTask extends StatefulWidget {
  const PageViewTask({super.key});

  @override
  State<PageViewTask> createState() => _PageViewTaskState();
}

class _PageViewTaskState extends State<PageViewTask> {
  // comment: controller for story view
  final StoryController storyController = StoryController();

  // comment: supabase client
  final supabase = Supabase.instance.client;

  // comment: list of banner images
  List<String> imageURls = [];

  // comment: loading state
  bool isLoading = true;

  // comment: load images from Supabase storage
  Future<void> loadImages() async {
    try {
      final List<FileObject> files =
          await supabase.storage.from('banner').list(path: 'banner');

      final urls = files.map((file) {
        return supabase.storage
            .from('banner')
            .getPublicUrl('banner/${file.name}');
      }).toList();

      if (!mounted) return;

      setState(() {
        imageURls = urls;
        isLoading = false;
      });
    } catch (e) {
      // comment: error handling
      debugPrint('Error loading images: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // comment: start loading images
    loadImages();
  }

  @override
  void dispose() {
    // comment: dispose story controller to free RAM
    storyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final base = media.size.shortestSide;

    // comment: responsive sizing
    final loaderSize = base * 0.07;

    // comment: convert URLs into story items
    final List<StoryItem> storyItem = imageURls.map((path) {
      return StoryItem.inlineImage(
        url: path,
        controller: storyController,
      );
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress(); // comment: ad on back
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.blackColor,

        body: isLoading
            ? Center(
                // comment: responsive loader
                child: SizedBox(
                  height: loaderSize * 2,
                  width: loaderSize * 2,
                  child: const CircularProgressIndicator(
                    color: Color(0xFF22C55E),
                  ),
                ),
              )
            : SafeArea(
                child: storyItem.isEmpty
                    ? Center(
                        // comment: empty state
                        child: Text(
                          "No banners found",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: base * 0.045,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            // comment: story view
                            child: StoryView(
                              storyItems: storyItem,
                              controller: storyController,

                              // comment: navigate after stories complete
                              onComplete: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const VideosFolder(),
                                  ),
                                );
                              },

                              // comment: swipe down to close
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FatafatScreen extends StatefulWidget {
  const FatafatScreen({super.key});

  @override
  State<FatafatScreen> createState() => _FatafatScreenState();
}

class _FatafatScreenState extends State<FatafatScreen> {
  late PageController _homePageController;
  late PageController _forYouPageController;



  final List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
  ].map((url) => url.trim()).toList(); // ✅ Fix trailing spaces

  // Separate controllers per tab to avoid conflicts
  final Map<String, Map<int, VideoPlayerController>> _allControllers = {
    'home': {},
    'forYou': {},
  };
 
  int _homeIndex = 0;
  int _forYouIndex = 0;

  @override
  void initState() {
    super.initState();
    _homePageController = PageController();
    _forYouPageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo('home', 0);
    });
  }

  Future<void> _initializeVideo(String tab, int index) async {
    final controllers = _allControllers[tab]!;

    // Skip if already initialized
    if (controllers.containsKey(index)) return;

    // ✅ CORRECT: Declare controller variable BEFORE using it
    final VideoPlayerController controller = VideoPlayerController.network(
      videoUrls[index].trim(), // Always trim URLs
    )..setLooping(true);

    try {
      // Store controller BEFORE initializing to avoid race conditions
      controllers[index] = controller;

      // Initialize and play if needed
      await controller.initialize();

      if (mounted) {
        final isActive = (tab == 'home' && index == _homeIndex) ||
            (tab == 'forYou' && index == _forYouIndex);
        if (isActive) {
          await controller.play();
        }
        setState(() {}); // Trigger UI update
      }
    } catch (e) {
      debugPrint('❌ Failed to load video [$tab:$index]: $e');
      controllers.remove(index);
      controller.dispose();
    }
  }

  void _managePlayback(String tab, int activeIndex) {
    final controllers = _allControllers[tab]!;
    controllers.forEach((index, controller) {
      if (index == activeIndex &&
          controller.value.isInitialized &&
          !controller.value.isPlaying) {
        controller.play();
      } else if (index != activeIndex && controller.value.isPlaying) {
        controller.pause();
      }
    });
  }

  @override
  void dispose() {
    _allControllers.values.forEach((controllers) {
      controllers.values.forEach((controller) => controller.dispose());
    });
    _homePageController.dispose();
    _forYouPageController.dispose();
    super.dispose();
  }

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


    return 
    // DefaultTabController(
    //   length: 2,
      // child:
       Scaffold(
        backgroundColor: Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20, ),
          ),
          title: Text(
            ' Live  Videos',
            style: TextStyle(
              fontSize:22 ,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),

          // actions: [
          //   Padding(
          //     padding: EdgeInsets.only(right: width * 0.03),
          //     child: CircleAvatar(
          //       child: Icon(Icons.person, size: iconSize * 0.7),
          //     ),
          //   ),
          // ],
          // bottom: TabBar(
          //   labelStyle: TextStyle(fontSize: titleFont * 0.9),
          //   tabs: [
          //     Tab(text: 'Home'),
          //     Tab(text: 'For You'),
          //   ],
          // ),

        ),
        body: Center(
          child: Text(
            'Live Videos',
            style: TextStyle(fontSize: 15.0),
          ),
        )

        // TabBarView(
        //   children: [
        //     _buildReelsFeed('home', _homePageController, _homeIndex, (index) {
        //       setState(() => _homeIndex = index);
        //       _managePlayback('home', index);
        //       if (index + 1 < videoUrls.length) {
        //         _initializeVideo('home', index + 1);
        //       }
        //     }),
        //     _buildReelsFeed('forYou', _forYouPageController, _forYouIndex, (
        //       index,
        //     ) {
        //       setState(() => _forYouIndex = index);
        //       _managePlayback('forYou', index);
        //       if (index + 1 < videoUrls.length) {
        //         _initializeVideo('forYou', index + 1);
        //       }
        //     }),
        //   ],
        // ),
     
      // ),
    );
  }

  // Widget _buildReelsFeed(
  //   String tab,
  //   PageController controller,
  //   int currentIndex,
  //   void Function(int) onPageChanged,
  // ) {
  //   return PageView.builder(
  //     controller: controller,
  //     scrollDirection: Axis.vertical,
  //     itemCount: videoUrls.length,
  //     itemBuilder: (context, index) {
  //       final controllers = _allControllers[tab]!;
  //       // Preload adjacent videos
  //       if (!controllers.containsKey(index) &&
  //           (index == currentIndex ||
  //               index == currentIndex - 1 ||
  //               index == currentIndex + 1)) {
  //         _initializeVideo(tab, index);
  //       }

  //       final videoController = controllers[index];

  //       return Stack(
  //         children: [
  //           // Ensures Flutter can paint this immediately and dismiss the splash
  //           const ColoredBox(color: Colors.black),

  //           if (videoController == null || !videoController.value.isInitialized)
  //             const Center(child: CircularProgressIndicator())
  //           else
  //             GestureDetector(
  //               onTap: () {
  //                 if (videoController.value.isPlaying) {
  //                   videoController.pause();
  //                 } else {
  //                   videoController.play();
  //                 }
  //               },
  //               child: Center(
  //                 child: AspectRatio(
  //                   aspectRatio: videoController.value.aspectRatio,
  //                   child: VideoPlayer(videoController),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       );
  //     },
  //     onPageChanged: onPageChanged,
  //   );
  // }

}

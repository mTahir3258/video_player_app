import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:player_app/Pages/detailed_videos.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:player_app/services/video_service.dart';
import 'package:player_app/model/system_video_model.dart';

// Screen that shows list of videos inside a folder
class ListOfVideos extends StatefulWidget {
  final String folderName; // Folder name shown in AppBar
  final String? folderPath; // Optional folder path (ID)

  ListOfVideos({
    super.key,
    required this.folderName,
    this.folderPath,
  });

  @override
  State<ListOfVideos> createState() => _ListOfVideosState();
}

class _ListOfVideosState extends State<ListOfVideos> {
  // List of videos from system
  List<SystemVideo> videos = [];

  // Loading indicator flag
  bool loading = true;

  //Interstitail Ads
  InterstitialAd? _interstitialAd;

  //Banner ads
  static BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdsHelper.loadBannerAds(onAdLoaded: () {
      setState(() {});
    });

    // fullScreenAds();
    loadVideos();
  }

  // //Google Ads Full Screem
  // void fullScreenAds() {
  //   AdsHelper.loadInterstitialAds(
  //     onLoaded: (ads) {
  //       _interstitialAd = ads;
  //       _interstitialAd?.show();
  //       setState(() {});
  //     },
  //     OnError: (Error) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text(
  //             'Full Screen ads not loaded',
  //             style: TextStyle(
  //                 fontSize: 15.0,
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.w500),
  //           )));
  //     },
  //   );
  // }

  // Load videos from system
  Future<void> loadVideos() async {
    if (widget.folderPath != null) {
      videos =
          await SystemVideoService.getVideos(folderPath: widget.folderPath);
    } else {
      videos = await SystemVideoService.getVideosFromFolder(widget.folderName);
    }

    setState(() => loading = false);
  }

  // Get video name from system using AssetEntity
  Future<String> getVideoNameFromSystem(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return "Unknown Video";
    return file.path.split('/').last;
  }

  // Safe getter for video name
  String getVideoName(SystemVideo video) {
    return video.name.isNotEmpty ? video.name : "Unknown Video";
  }

  // Delete video from system
  void _deleteVideo(SystemVideo video, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF0D1117),
        title: const Text(
          "Delete Video",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Are you sure you want to delete this video?",
          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF22C55E)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFF22C55E)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final bool success =
          await SystemVideoService.deleteVideo(video.assetId as AssetEntity);

      if (success) {
        setState(() {
          videos.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Color(0xFF22C55E),
              content: Text("Video deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Failed to delete video")),
        );
      }
    }
  }

  // Rename video (UI only)
  void renameVideo({
    required SystemVideo video,
    required int index,
  }) {
    final TextEditingController controller =
        TextEditingController(text: video.name);

    bool isFocused = false; //focusing hint style and color

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF0D1117),
          title: const Text(
            "Rename Video",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Focus(
                onFocusChange: (focus) {
                  setStateDialog(() => isFocused = focus);
                },
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter new name",
                    hintStyle: TextStyle(
                      color: isFocused ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.7, color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.7, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF22C55E)),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  videos[index] = SystemVideo(
                    path: video.path,
                    name: controller.text.trim(),
                    duration: video.duration,
                    assetId: video.assetId,
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Color(0xFF22C55E),
                      content: Text(
                        "Video renamed",
                      )),
                );
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Color(0xFF22C55E)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Bottom sheet for video options
  void showVideoOptionsBottomSheet({
    required BuildContext context,
    required String videoName,
    required VoidCallback onDelete,
    required VoidCallback onRename,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF0D1117),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    videoName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF22C55E)),
                  title: const Text(
                    "Rename",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onRename();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Color(0xFF22C55E)),
                  title: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    final horizontalPadding = width * 0.04;
    final verticalPadding = height * 0.015;
    final containerPadding = width * 0.04;
    final thumbnailWidth = width * 0.2;
    final thumbnailHeight = height * 0.08;
    final textFontSize = width * 0.045;
    final iconSize = width * 0.065;

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Text(
            widget.folderName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                color: Color(0xFF22C55E),
              ))
            : videos.isEmpty
                ? _buildNoVideosFound()
                : Column(
                    children: [
                      if (_bannerAd != null)
                        Container(
                          height: _bannerAd!.size.height.toDouble(),
                          width: _bannerAd!.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailedVideos(
                                              videoPath: video.path,
                                              videoList: video.name)));
                                },
                                leading: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D1117),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.movie_outlined,
                                        color: Colors.white24,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  ],
                                ),
                                title: Text(
                                  video.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "${video.duration} • Video", // You can format size here if available
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert,
                                      color: Color(0xFF22C55E)),
                                  onPressed: () {
                                    // Call your bottom sheet or options logic here
                                    showVideoOptionsBottomSheet(
                                      context: context,
                                      videoName: getVideoName(videos[index]),
                                      onDelete: () =>
                                          _deleteVideo(videos[index], index),
                                      onRename: () => renameVideo(
                                        video: videos[index],
                                        index: index,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildNoVideosFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined,
              size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No videos found',
            style: TextStyle(color: Colors.white54),
          ),
          TextButton(
            onPressed: loadVideos,
            child: const Text('Refresh',
                style: TextStyle(color: Color(0xFF22C55E))),
          )
        ],
      ),
    );
  }
}

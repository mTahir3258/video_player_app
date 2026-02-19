import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:player_app/Pages/detailed_videos.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:player_app/services/video_service.dart';
import 'package:player_app/model/system_video_model.dart';

// ✅ Screen that shows list of videos inside a folder
class ListOfVideos extends StatefulWidget {
  final String folderName;  // ✅ Folder name
  final String? folderPath; // ✅ Optional folder ID

  const ListOfVideos({
    super.key,
    required this.folderName,
    this.folderPath,
  });

  @override
  State<ListOfVideos> createState() => _ListOfVideosState();
}

class _ListOfVideosState extends State<ListOfVideos> {

  // ✅ List of videos
  List<SystemVideo> videos = [];

  bool loading = true; // ✅ Loading state

  // ✅ Ads
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    // ✅ Load banner ad
    _bannerAd = AdsHelper.loadBannerAds(onAdLoaded: () {
      if (!mounted) return;
      setState(() {});
    });

    // ✅ Load videos
    loadVideos();
  }

  // ✅ Load videos from system
  Future<void> loadVideos() async {

    if (widget.folderPath != null) {
      videos = await SystemVideoService.getVideos(
        folderPath: widget.folderPath,
      );
    } else {
      videos = await SystemVideoService.getVideosFromFolder(
        widget.folderName,
      );
    }

    if (!mounted) return;

    // ✅ Stop loader
    setState(() => loading = false);
  }

  // ✅ Safe video name
  String getVideoName(SystemVideo video) {
    return video.name.isNotEmpty ? video.name : "Unknown Video";
  }

  // ✅ Delete video
  void _deleteVideo(SystemVideo video, int index) async {

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),

        title: const Text(
          "Delete Video",
          style: TextStyle(color: Colors.white),
        ),

        content: const Text(
          "Are you sure you want to delete?",
          style: TextStyle(color: Colors.white54),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFF22C55E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style: TextStyle(color: Color(0xFF22C55E))),
          ),
        ],
      ),
    );

    if (confirm == true) {

      // ✅ Delete using assetId
      final success = await SystemVideoService.deleteVideo(
        video.assetId as AssetEntity,
      );

      if (!mounted) return;

      if (success) {
        setState(() => videos.removeAt(index));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF22C55E),
            content: Text("Video deleted"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Delete failed"),
          ),
        );
      }
    }
  }

  // ✅ Rename video (UI only)
  void renameVideo({
    required SystemVideo video,
    required int index,
  }) {
    final controller = TextEditingController(text: video.name);
    bool isFocused = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117),

          title: const Text(
            "Rename Video",
            style: TextStyle(color: Colors.white),
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
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFF22C55E))),
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
                    content: Text("Video renamed"),
                  ),
                );
              },
              child: const Text("Save",
                  style: TextStyle(color: Color(0xFF22C55E))),
            ),
          ],
        );
      },
    );
  }

  // ✅ Bottom sheet options
  void showVideoOptionsBottomSheet({
    required String videoName,
    required VoidCallback onDelete,
    required VoidCallback onRename,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ✅ Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ✅ Video name
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  videoName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(),

              // ✅ Rename
              ListTile(
                leading:
                    const Icon(Icons.edit, color: Color(0xFF22C55E)),
                title: const Text("Rename",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  onRename();
                },
              ),

              // ✅ Delete
              ListTile(
                leading:
                    const Icon(Icons.delete, color: Color(0xFF22C55E)),
                title: const Text("Delete",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context);
    final size = media.size;

    // ✅ Responsive base unit
    final base = size.shortestSide;

    final tilePadding = base * 0.035;
    final iconSize = base * 0.065;
    final thumbWidth = base * 0.22;
    final thumbHeight = base * 0.16;
    final titleSize = base * 0.042;
    final subSize = base * 0.032;

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress(); // ✅ Handle ads
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),

        // ✅ AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          title: Text(
            widget.folderName,
            style: TextStyle(
              fontSize: base * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: base * 0.05,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF22C55E),
                ),
              )
            : videos.isEmpty
                ? _buildNoVideosFound(base)
                : Column(
                    children: [

                      // ✅ Banner Ad
                      if (_bannerAd != null)
                        SizedBox(
                          height:
                              _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),

                      // ✅ Video list
                      Expanded(
                        child: ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (context, index) {

                            final video = videos[index];

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: base * 0.04,
                                vertical: base * 0.025,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                borderRadius:
                                    BorderRadius.circular(base * 0.04),
                              ),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.all(tilePadding),

                                // ✅ Open player
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailedVideos(
                                        videoPath: video.path,
                                        videoList: video.name,
                                      ),
                                    ),
                                  );
                                },

                                // ✅ Thumbnail
                                leading: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: thumbWidth,
                                      height: thumbHeight,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFF0D1117),
                                        borderRadius:
                                            BorderRadius.circular(base * 0.02),
                                      ),
                                      child: Icon(
                                        Icons.movie_outlined,
                                        color: Colors.white24,
                                        size: iconSize,
                                      ),
                                    ),
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: iconSize,
                                    )
                                  ],
                                ),

                                // ✅ Video name
                                title: Text(
                                  getVideoName(video),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // ✅ Duration
                                subtitle: Text(
                                  "${video.duration} • Video",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: subSize,
                                  ),
                                ),

                                // ✅ Options button
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Color(0xFF22C55E),
                                  ),
                                  onPressed: () {
                                    showVideoOptionsBottomSheet(
                                      videoName:
                                          getVideoName(video),
                                      onDelete: () =>
                                          _deleteVideo(video, index),
                                      onRename: () =>
                                          renameVideo(video: video, index: index),
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

  // ✅ No videos UI
  Widget _buildNoVideosFound(double base) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined,
              size: base * 0.18, color: Colors.white24),
          SizedBox(height: base * 0.04),
          const Text(
            'No videos found',
            style: TextStyle(color: Colors.white54),
          ),
          TextButton(
            onPressed: loadVideos,
            child: const Text(
              'Refresh',
              style: TextStyle(color: Color(0xFF22C55E)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ✅ Dispose ads
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }
}

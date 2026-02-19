import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:player_app/Pages/detailed_videos.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:player_app/model/system_video_model.dart';
import 'package:player_app/model/video_playList.dart';
import 'package:player_app/state/playlist_notifier.dart';

class Playlistcreatedscreen extends StatefulWidget {
  final VideoPlaylist playlist;

  const Playlistcreatedscreen({super.key, required this.playlist});

  @override
  State<Playlistcreatedscreen> createState() => _PlaylistcreatedscreenState();
}

class _PlaylistcreatedscreenState extends State<Playlistcreatedscreen> {
  List<SystemVideo> videos = [];

  // comment: interstitial ad variable
  InterstitialAd? _interstitialAd;

  // comment: banner ad variable
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    // comment: copy playlist videos into local list
    videos = List<SystemVideo>.from(widget.playlist.videos);

    // comment: load banner ad
    _bannerAd = AdsHelper.loadBannerAds(
      onAdLoaded: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    // comment: dispose ads to free RAM
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }

  // comment: delete video from playlist
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
          "Are you sure you want to delete this video?",
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

    if (confirm != true) return;

    final updatedVideos = List<SystemVideo>.from(videos);
    updatedVideos.removeAt(index);

    setState(() => videos = updatedVideos);

    widget.playlist.videos = updatedVideos;
    await widget.playlist.save();

    if (updatedVideos.isEmpty) {
      await widget.playlist.delete();
    }

    playlistNotifier.loadPlaylists();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF22C55E),
        content: Text("Video deleted"),
      ),
    );
  }

  // comment: rename video (UI only)
  void renameVideo({
    required SystemVideo video,
    required int index,
  }) {
    final controller = TextEditingController(text: video.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117),
          title: const Text(
            "Rename Video",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter new name",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose(); // comment: dispose controller
                Navigator.pop(context);
              },
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFF22C55E))),
            ),
            TextButton(
              onPressed: () async {
                final updatedVideos = List<SystemVideo>.from(videos);

                updatedVideos[index] = SystemVideo(
                  path: video.path,
                  name: controller.text.trim(),
                  duration: video.duration,
                  assetId: video.assetId,
                );

                setState(() => videos = updatedVideos);

                widget.playlist.videos = updatedVideos;
                await widget.playlist.save();

                playlistNotifier.loadPlaylists();

                controller.dispose(); // comment: dispose controller
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

  // comment: bottom sheet options
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
              const SizedBox(height: 10),

              // comment: title
              Text(
                videoName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

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
    final base = media.size.shortestSide;

    // comment: responsive scaling
    final thumbnailHeight = base * 0.18;
    final iconSize = base * 0.07;
    final fontSize = base * 0.040;

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress(); // comment: show ad on back
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                size: iconSize, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.playlist.name,
            style: TextStyle(
              fontSize: base * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // comment: banner ad
            if (_bannerAd != null)
              SizedBox(
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
                    margin: EdgeInsets.symmetric(
                      horizontal: base * 0.04,
                      vertical: base * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(base * 0.04),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(base * 0.025),

                      // comment: thumbnail
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: thumbnailHeight,
                            width: base * 0.2,
                            
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius:
                                  BorderRadius.circular(base * 0.02),
                            ),
                            child: Icon(Icons.movie,
                                color: Colors.white24, size: iconSize),
                          ),
                      
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          
                        ],
                      ),

                      // comment: video name
                      title: Text(
                        video.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      // comment: options
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert,
                            size: iconSize,
                            color: const Color(0xFF22C55E)),
                        onPressed: () {
                          showVideoOptionsBottomSheet(
                            videoName: video.name,
                            onDelete: () =>
                                _deleteVideo(video, index),
                            onRename: () =>
                                renameVideo(video: video, index: index),
                          );
                        },
                      ),

                      // comment: open video
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
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photo_manager/src/types/entity.dart';
import 'package:player_app/Pages/detailed_videos.dart';
import 'package:player_app/model/system_video_model.dart';
import 'package:player_app/model/video_playList.dart';
import 'package:player_app/services/video_service.dart';
import 'package:player_app/state/playlist_notifier.dart';

class Playlistcreatedscreen extends StatefulWidget {
  final VideoPlaylist playlist;

  const Playlistcreatedscreen({super.key, required this.playlist});

  @override
  State<Playlistcreatedscreen> createState() => _PlaylistcreatedscreenState();
}

class _PlaylistcreatedscreenState extends State<Playlistcreatedscreen> {
  List<SystemVideo> videos = [];

  void savePlaylist(VideoPlaylist playlist) async {
    final box = Hive.box<VideoPlaylist>('playlistBox');
    await box.add(playlist);
  }

  void getPlaylist() async {
    final box = Hive.box<VideoPlaylist>('playlistBox');
    await box.values.toList();
  }

  @override
  void initState() {
    super.initState();
    videos = List<SystemVideo>.from(widget.playlist.videos);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final thumbnailWidth = width * 0.2;
    final thumbnailHeight = height * 0.08;

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
            style:
                TextStyle(color: Colors.white54, fontWeight: FontWeight.w500),
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

      if (confirm != true) return;
      //create new list copy

      final updatedVideos = List<SystemVideo>.from(videos);

      //remove only tapped video
      updatedVideos.removeAt(index);

      if (confirm == true) {
        setState(() {
          //update local Ui list
          videos = updatedVideos;
        });

        //update hive playlist
        widget.playlist.videos = updatedVideos;

        //save hive changes
        await widget.playlist.save();

        //check if playlist is empty
        if (updatedVideos.isEmpty)

          //delete playlist from hive
          await widget.playlist.delete();
          
        playlistNotifier.loadPlaylists();

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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                onPressed: () async {
                  setState(() {
                    final updatedVideos = List<SystemVideo>.from(videos);

                    updatedVideos[index] = SystemVideo(
                      path: video.path,
                      name: controller.text.trim(),
                      duration: video.duration,
                      assetId: video.assetId,
                    );

                    videos = updatedVideos;

                    //update playlist in Hive
                    widget.playlist.videos = updatedVideos;
                  });

                  //save the playlist
                  await widget.playlist.save();

                  playlistNotifier.loadPlaylists();

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

    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          widget.playlist.name,
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(15.0)),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DetailedVideos(
                      videoPath: video.path, videoList: video.name);
                }));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                        ),
                      ),
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  title: Text(
                    '${video.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        showVideoOptionsBottomSheet(
                            context: context,
                            videoName: getVideoName(videos[index]),
                            onDelete: () => _deleteVideo(videos[index], index),
                            onRename: () => renameVideo(
                                video: videos[index], index: index));
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Color(0xFF22C55E),
                      )),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

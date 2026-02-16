import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:player_app/Pages/screens/playlistcreatedScreen.dart';
import 'package:player_app/model/system_video_model.dart';
import 'package:player_app/model/video_playList.dart';
import 'package:player_app/state/playlist_notifier.dart';

class PlayListScreen extends StatefulWidget {
  final List<SystemVideo> availableVideos;
  const PlayListScreen({super.key, required this.availableVideos});

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _createPlaylist() {
    final TextEditingController nameController = TextEditingController();
    final List<SystemVideo> selectedVideos = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modelContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modelContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: _formKey,
                child: SizedBox(
                  height: MediaQuery.of(modelContext).size.height * 0.7,
                  child: Column(
                    children: [
                      const Text(
                        "Create Playlist",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Playlist name",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Enter name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.availableVideos.length,
                          itemBuilder: (context, index) {
                            final video = widget.availableVideos[index];
                            final isSelected = selectedVideos.contains(video);

                            return CheckboxListTile(
                              checkColor: Colors.black,
                              activeColor: const Color(0xFF1ED760),
                              value: isSelected,
                              title: Text(
                                video.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    selectedVideos.add(video);
                                  } else {
                                    selectedVideos.remove(video);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                          height: 50.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1ED760),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              if (selectedVideos.isEmpty) return;

                              //create playlist object
                              final playlist = VideoPlaylist(
                                  name: nameController.text.trim(),
                                  // videos: List.from(selectedVideos)
                                  videos: List.from(selectedVideos));

                              // add playlist into the Hive
                              final box = Hive.box<VideoPlaylist>(
                                'playlistBox',
                              );

                              playlistNotifier.addPlaylist(playlist);

                              // await box.add(playlist);

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('PlayList Created'),
                                backgroundColor: Color(0xFF22C55E),
                              ));
                            },
                            child: const Text(
                              "Create",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              )),
          title: const Text(
            "Playlists",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          )),
      floatingActionButton: GestureDetector(
        onTap: () {
          _createPlaylist();
        },
        child: Container(
          height: screenHeight * 0.08,
          width: screenWidth * 0.160,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.add,
            color: Color(0xFF22C55E),
            size: 30,
          ),
        ),
      ),

      // 🔥 THIS IS IMPORTANT
      body: ValueListenableBuilder(
        valueListenable: playlistNotifier,
        builder: (context, List<VideoPlaylist> playlists, _) {
          if (playlists.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(
                    Icons.playlist_play,
                    color: Color(0xFF1ED760),
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${playlist.videos.length} videos",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Playlistcreatedscreen(
                          playlist: playlist,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(
              Icons.library_add,
              size: 60,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          const Text(
            'No Playlists created',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start Organizing your favorite track by creating your first playlist',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:player_app/Pages/screens/playlistcreatedScreen.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
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

  // comment: banner ad
  BannerAd? _bannerAd;

  // comment: interstitial ad
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

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

  // comment: open create playlist bottom sheet
  void _createPlaylist() {
    final TextEditingController nameController = TextEditingController();
    final List<SystemVideo> selectedVideos = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modelContext) {
        final media = MediaQuery.of(modelContext);
        final base = media.size.shortestSide;

        // comment: responsive sizing
        final fontSize = base * 0.045;
        final padding = base * 0.04;

        return Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom,
            left: padding,
            right: padding,
            top: padding,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: _formKey,
                child: SizedBox(
                  height: media.size.height * 0.75,
                  child: Column(
                    children: [
                      // comment: title
                      Text(
                        "Create Playlist",
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: padding),

                      // comment: playlist name input
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Playlist name",
                          hintStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(base * 0.03),
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

                      SizedBox(height: padding * 0.6),

                      // comment: video list
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.availableVideos.length,
                          itemBuilder: (context, index) {
                            final video = widget.availableVideos[index];
                            final isSelected =
                                selectedVideos.contains(video);

                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: const Color(0xFF1ED760),
                              checkColor: Colors.black,
                              title: Text(
                                video.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: base * 0.040,
                                ),
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

                      SizedBox(height: padding),

                      // comment: create button
                      SizedBox(
                        width: double.infinity,
                        height: base * 0.13,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ED760),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(base * 0.08),
                            ),
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (selectedVideos.isEmpty) return;

                            // comment: create playlist object
                            final playlist = VideoPlaylist(
                              name: nameController.text.trim(),
                              videos: List.from(selectedVideos),
                            );

                            // comment: save playlist
                            playlistNotifier.addPlaylist(playlist);

                            // comment: dispose controller
                            // nameController.dispose();

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Playlist Created'),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                          },
                          child: Text(
                            "Create",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: base * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: padding),
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
    final media = MediaQuery.of(context);
    final base = media.size.shortestSide;

    // comment: responsive sizing
    final iconSize = base * 0.06;
    final fabSize = base * 0.14;
    final fontSize = base * 0.05;

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress(); // comment: show ad on back
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),

        // comment: app bar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: iconSize, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Playlists",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),

        // comment: floating button
        floatingActionButton: SizedBox(
          height: fabSize,
          width: fabSize,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF161B22),
            onPressed: _createPlaylist,
            child: Icon(Icons.add,
                size: iconSize * 1.2,
                color: const Color(0xFF22C55E)),
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
              child: ValueListenableBuilder(
                valueListenable: playlistNotifier,
                builder: (context, List<VideoPlaylist> playlists, _) {
                  if (playlists.isEmpty) {
                    return _buildEmptyState(base);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(base * 0.04),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];

                      return Container(
                        margin:
                            EdgeInsets.only(bottom: base * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(base * 0.035),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.playlist_play,
                              size: iconSize,
                              color: const Color(0xFF1ED760)),

                          title: Text(
                            playlist.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: base * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            "${playlist.videos.length} videos",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: base * 0.035,
                            ),
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    Playlistcreatedscreen(
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
            ),
          ],
        ),
      ),
    );
  }

  // comment: empty UI
  Widget _buildEmptyState(double base) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(base * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_add,
                size: base * 0.18,
                color: Colors.white24),

            SizedBox(height: base * 0.06),

            Text(
              'No Playlists created',
              style: TextStyle(
                color: Colors.white,
                fontSize: base * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: base * 0.02),

            Text(
              'Create your first playlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: base * 0.040,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

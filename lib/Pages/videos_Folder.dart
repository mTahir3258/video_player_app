import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:player_app/Pages/list_of_videos.dart';
import 'package:player_app/Pages/screens/playlist_screen.dart';
import 'package:player_app/google_ads_files/ads_helper.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';
import 'package:player_app/model/horizontal_folderlist_model.dart';
import 'package:player_app/model/video_model.dart';
import 'package:player_app/services/video_service.dart';

class VideosFolder extends StatefulWidget {
  const VideosFolder({super.key});

  @override
  State<VideosFolder> createState() => _VideosFolderState();
}

class _VideosFolderState extends State<VideosFolder> {
  final TextEditingController _textController = TextEditingController();
  bool _isSearching = false;
  bool _loading = true;

  //Interestitail Ads
  InterstitialAd? _interstitialAd;

  //Banner Ads instance
  static BannerAd? _bannerAd;

  List<VideoFolder> folders = [];
  List<VideoFolder> allFolders = [];
  List<String> folderIds = [];
  List<String> allFolderIds = [];

  final List<HorizontalFolderlistModel> horizontalFolders = [
    HorizontalFolderlistModel(
      iconsName: Icons.playlist_add,
      folderName: 'Playlist',
    ),
  ];

  @override
  void initState() {
    super.initState();

    //Banner Ads
    _bannerAd = AdsHelper.loadBannerAds(
      onAdLoaded: () {
        setState(() {
          // _loading = true;
        });
      },
    );

    //===full screen ads ====
    // fullscreenAds();
    _loadVideoFolders();
  }

// full screen ads
  void fullscreenAds() {
    AdsHelper.loadInterstitialAds(onLoaded: (ads) {
      _interstitialAd = ads;
      _interstitialAd?.show();

      setState(() {});
    }, OnError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Full Screen ad is not loaded ',
        style: TextStyle(
            fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.w500),
      )));
      setState(() {});
    });
  }

  Future<void> _loadVideoFolders() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) {
      setState(() => _loading = false);
      return;
    }

    final paths = await PhotoManager.getAssetPathList(type: RequestType.video);

    final List<VideoFolder> temp = [];
    final List<String> tempIds = [];

    for (final path in paths) {
      final count = await path.assetCountAsync;
      if (count == 0) continue;

      temp.add(VideoFolder(
        icon: Icons.folder,
        title: path.name,
        subtitle: '$count Videos',
      ));
      tempIds.add(path.id);
    }

    folders = temp;
    allFolders = List.from(temp);
    folderIds = tempIds;
    allFolderIds = List.from(tempIds);

    setState(() => _loading = false);
  }

  void _filterFolders(String query) {
    final lower = query.toLowerCase();
    setState(() {
      folders = allFolders
          .where((f) => f.title.toLowerCase().contains(lower))
          .toList();

      folderIds = folders.map((f) {
        final i = allFolders.indexOf(f);
        return allFolderIds[i];
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final shortestSide = media.size.shortestSide;

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
          leading: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          title: _isSearching
              ? TextField(
                  controller: _textController,
                  onChanged: _filterFolders,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search Folders...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                )
              : const Text(
                  'Folders',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _textController.clear();
                    _filterFolders('');
                  }
                });
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: height * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: horizontalFolders.length,
                  itemBuilder: (context, index) {
                    final item = horizontalFolders[index];
                    return InkWell(
                      onTap: () async {
                        final videos = await SystemVideoService.getVideos();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayListScreen(
                              availableVideos: videos,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          height: height * 0.08,
                          width: width * 0.160,
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
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Color(0xFF22C55E),
                      ))
                    : ListView.builder(
                        itemCount: folders.isEmpty ? 0 : folders.length * 2 - 1,
                        itemBuilder: (context, index) {
                          if (index.isOdd) {
                            if (_bannerAd == null) {
                              return const SizedBox();
                            }
                            return Container(
                              alignment: Alignment.center,
                              height: _bannerAd!.size.height.toDouble(),
                              width: _bannerAd!.size.width.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            );
                          }
                          final folderIndex = index ~/ 2;

                          if (folderIndex >= folders.length) {
                            return const SizedBox();
                          }
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12.0),
                              leading: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1117),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIcon(folders[folderIndex].title),
                                  color:
                                      _getIconColor(folders[folderIndex].title),
                                ),
                              ),
                              title: Text(
                                folders[folderIndex].title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                folders[folderIndex].subtitle,
                                style: TextStyle(color: Colors.white54),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white24,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListOfVideos(
                                      folderName: folders[folderIndex].title,
                                      folderPath: folderIds[folderIndex],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper to match icons from your screenshot
  IconData _getIcon(String title) {
    if (title.contains('Recent')) return Icons.folder_copy;
    if (title.contains('Camera')) return Icons.camera_alt;
    return Icons.file_download;
  }

  Color _getIconColor(String title) {
    if (title.contains('Recent')) return const Color(0xFF22C55E);
    if (title.contains('Camera')) return Colors.blueAccent;
    return Colors.orangeAccent;
  }
}

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

  // ✅ Controller for search field
  final TextEditingController _textController = TextEditingController();

  bool _isSearching = false; // ✅ Search mode toggle
  bool _loading = true;       // ✅ Loading state

  // ✅ Interstitial Ad
  InterstitialAd? _interstitialAd;

  // ✅ Banner Ad
  BannerAd? _bannerAd;

  // ✅ Folder lists
  List<VideoFolder> folders = [];
  List<VideoFolder> allFolders = [];

  // ✅ Folder IDs
  List<String> folderIds = [];
  List<String> allFolderIds = [];

  // ✅ Top horizontal menu
  final List<HorizontalFolderlistModel> horizontalFolders = [
    HorizontalFolderlistModel(
      iconsName: Icons.playlist_add,
      folderName: 'Playlist',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Load banner ad
    _bannerAd = AdsHelper.loadBannerAds(
      onAdLoaded: () {
        if (!mounted) return;
        setState(() {});
      },
    );

    // ✅ Load folders
    _loadVideoFolders();
  }

  // ✅ Load folders from device
  Future<void> _loadVideoFolders() async {

    // ✅ Request permission
    final PermissionState ps =
        await PhotoManager.requestPermissionExtend();

    // ❌ If permission denied → stop loading
    if (!ps.isAuth) {
      setState(() => _loading = false);
      return;
    }

    // ✅ Get video folders
    final paths =
        await PhotoManager.getAssetPathList(type: RequestType.video);

    final List<VideoFolder> temp = [];
    final List<String> tempIds = [];

    for (final path in paths) {

      // ✅ Get video count
      final count = await path.assetCountAsync;

      // ❌ Skip empty folders
      if (count == 0) continue;

      // ✅ Add folder UI model
      temp.add(VideoFolder(
        icon: Icons.folder,
        title: path.name,
        subtitle: '$count Videos',
      ));

      // ✅ Store folder ID
      tempIds.add(path.id);
    }

    // ✅ Save lists
    folders = temp;
    allFolders = List.from(temp);

    folderIds = tempIds;
    allFolderIds = List.from(tempIds);

    // ✅ Stop loader
    setState(() => _loading = false);
  }

  // ✅ Filter folders when searching
  void _filterFolders(String query) {
    final lower = query.toLowerCase();

    setState(() {
      folders = allFolders
          .where((f) => f.title.toLowerCase().contains(lower))
          .toList();

      // ✅ Map correct IDs
      folderIds = folders.map((f) {
        final i = allFolders.indexOf(f);
        return allFolderIds[i];
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context);
    final size = media.size;

    // ✅ Base unit for responsiveness
    final base = size.shortestSide;

    final padding = base * 0.04;
    final iconSize = base * 0.065;
    final tileRadius = base * 0.05;
    final horizontalHeight = base * 0.18;

    return WillPopScope(
      onWillPop: () async {
        // ✅ Handle interstitial logic
        AdsManager.handelBackPress();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          leading: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),

          // ✅ Title or Search Field
          title: _isSearching
              ? TextField(
                  controller: _textController,
                  onChanged: _filterFolders,

                  // ✅ Typed text color
                  style: const TextStyle(color: Colors.white),

                  decoration: const InputDecoration(
                    hintText: 'Search Folders...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                )
              : const Text(
                  'Folders',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
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

                  // ✅ Reset search
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
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [

              // ✅ Horizontal top button
              SizedBox(
                height: horizontalHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: horizontalFolders.length,
                  itemBuilder: (context, index) {

                    final item = horizontalFolders[index];

                    return InkWell(
                      onTap: () async {

                        // ✅ Load all videos
                        final videos =
                            await SystemVideoService.getVideos();

                        if (!mounted) return;

                        // ✅ Open playlist screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayListScreen(
                              availableVideos: videos,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: base * 0.22,
                        margin: EdgeInsets.only(right: base * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius:
                              BorderRadius.circular(base * 0.045),
                        ),
                        child: Icon(
                          Icons.add,
                          color: const Color(0xFF22C55E),
                          size: iconSize,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: base * 0.03),

              // ✅ Folder list
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF22C55E),
                        ),
                      )
                    : ListView.builder(

                        // ✅ Insert ads between items
                        itemCount:
                            folders.isEmpty ? 0 : folders.length * 2 - 1,

                        itemBuilder: (context, index) {

                          // ✅ Show ad at odd positions
                          if (index.isOdd) {
                            if (_bannerAd == null) {
                              return const SizedBox();
                            }

                            return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(
                                  vertical: base * 0.02),

                              height:
                                  _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            );
                          }

                          final folderIndex = index ~/ 2;

                          if (folderIndex >= folders.length) {
                            return const SizedBox();
                          }

                          final folder = folders[folderIndex];

                          return Container(
                            margin:
                                EdgeInsets.only(bottom: base * 0.03),

                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius:
                                  BorderRadius.circular(tileRadius),
                            ),

                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.all(base * 0.035),

                              // ✅ Folder icon
                              leading: Container(
                                padding:
                                    EdgeInsets.all(base * 0.03),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1117),
                                  borderRadius:
                                      BorderRadius.circular(
                                          base * 0.03),
                                ),
                                child: Icon(
                                  _getIcon(folder.title),
                                  color:
                                      _getIconColor(folder.title),
                                  size: iconSize,
                                ),
                              ),

                              // ✅ Folder title
                              title: Text(
                                folder.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: base * 0.045,
                                ),
                              ),

                              // ✅ Folder subtitle
                              subtitle: Text(
                                folder.subtitle,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: base * 0.035,
                                ),
                              ),

                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white24,
                                size: base * 0.04,
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListOfVideos(
                                      folderName: folder.title,
                                      folderPath:
                                          folderIds[folderIndex],
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

  // ✅ Choose icon based on folder name
  IconData _getIcon(String title) {
    if (title.contains('Recent')) return Icons.folder_copy;
    if (title.contains('Camera')) return Icons.camera_alt;
    return Icons.file_download;
  }

  // ✅ Choose icon color
  Color _getIconColor(String title) {
    if (title.contains('Recent')) return const Color(0xFF22C55E);
    if (title.contains('Camera')) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  @override
  void dispose() {
    // ✅ Dispose controller
    _textController.dispose();

    // ✅ Dispose ads
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }
}

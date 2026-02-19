import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/services.dart';
import 'package:player_app/google_ads_files/ads_manager.dart';

// ✅ Video Player Screen
class DetailedVideos extends StatefulWidget {
  final String videoPath; // ✅ Path of video
  final String videoList; // ✅ Video title

  const DetailedVideos({
    super.key,
    required this.videoPath,
    required this.videoList,
  });

  @override
  State<DetailedVideos> createState() => _DetailedVideosState();
}

class _DetailedVideosState extends State<DetailedVideos> {

  late final Player _player;                 // ✅ MediaKit player
  late final VideoController _videoController; // ✅ Video controller

  bool _isLocked = false;       // ✅ Lock controls flag
  bool _showControls = true;    // ✅ Show/hide controls
  bool _isFullscreen = false;   // ✅ Fullscreen flag

  BoxFit _currentFit = BoxFit.contain; // ✅ Video fit mode
  double _playbackSpeed = 1.0;         // ✅ Speed value

  // ✅ Speed options
  final List<double> _speedOptions = [
    0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0,
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Create player
    _player = Player();

    // ✅ Attach controller
    _videoController = VideoController(_player);

    // ✅ Start playing video
    _player.open(Media(widget.videoPath));
  }

  @override
  void dispose() {

    // ✅ Restore UI when leaving screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // ✅ Dispose player (important for RAM)
    _player.dispose();

    super.dispose();
  }

  // ✅ Play / Pause
  void _togglePlayPause() {
    if (_player.state.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  // ✅ Seek forward 10 sec
  void _seekForward() {
    final pos = _player.state.position;
    _player.seek(pos + const Duration(seconds: 10));
  }

  // ✅ Seek backward 10 sec
  void _seekBackward() {
    final pos = _player.state.position;
    final newPos = pos - const Duration(seconds: 10);
    _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  // ✅ Toggle fullscreen
  void _toggleFullscreen() async {
    if (_isFullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    setState(() => _isFullscreen = !_isFullscreen);
  }

  // ✅ Change video fit
  void _toggleFit() {
    setState(() {
      _currentFit = _currentFit == BoxFit.contain
          ? BoxFit.cover
          : _currentFit == BoxFit.cover
              ? BoxFit.fill
              : BoxFit.contain;
    });
  }

  // ✅ Format duration
  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}";
  }

  // ✅ Show speed selector
  void _showSpeedDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _speedOptions.map((speed) {
              final selected = speed == _playbackSpeed;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _playbackSpeed = speed;
                    _player.setRate(speed);
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.blue : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${speed}x",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context);
    final base = media.size.shortestSide; // ✅ Responsive base

    final iconSize = base * 0.075; // ✅ Icon scale
    final padding = base * 0.03;   // ✅ Padding scale
    final textSize = base * 0.045; // ✅ Text scale

    return WillPopScope(
      onWillPop: () async {
        AdsManager.handelBackPress(); // ✅ Show ad on back
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,

        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (_isLocked) return;

              // ✅ Show / hide controls
              setState(() => _showControls = !_showControls);
            },
            child: Stack(
              children: [

                // ✅ Video Player
                Positioned.fill(
                  child: Video(
                    controller: _videoController,
                    fit: _currentFit,
                    controls: null,
                  ),
                ),

                // ✅ Controls Overlay
                if (_showControls && !_isLocked) ...[

                  // 🔝 Top bar
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        children: [

                          // Back button
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: Colors.white, size: iconSize),
                            onPressed: () => Navigator.pop(context),
                          ),

                          // Video title
                          Expanded(
                            child: Text(
                              widget.videoList,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize,
                              ),
                            ),
                          ),

                          // Speed button
                          IconButton(
                            icon: Icon(Icons.speed,
                                color: Colors.white, size: iconSize),
                            onPressed: _showSpeedDialog,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔻 Bottom controls
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ✅ Progress bar
                          StreamBuilder<Duration>(
                            stream: _player.stream.position,
                            builder: (context, snapshot) {

                              final pos = snapshot.data ?? Duration.zero;
                              final dur = _player.state.duration;

                              return Column(
                                children: [

                                  Slider(
                                    min: 0,
                                    max: dur.inMilliseconds.toDouble(),
                                    value: pos.inMilliseconds
                                        .clamp(0, dur.inMilliseconds)
                                        .toDouble(),
                                    onChanged: (v) => _player.seek(
                                      Duration(milliseconds: v.toInt()),
                                    ),
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_format(pos),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text(_format(dur),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: padding),

                          // ✅ Buttons row
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [

                              _control(
                                icon: _isLocked
                                    ? Icons.lock
                                    : Icons.lock_open,
                                size: iconSize,
                                onTap: () {
                                  setState(() => _isLocked = !_isLocked);
                                },
                              ),

                              _control(
                                  icon: Icons.replay_10,
                                  size: iconSize,
                                  onTap: _seekBackward),

                              StreamBuilder<bool>(
                                stream: _player.stream.playing,
                                builder: (context, snapshot) {
                                  return _control(
                                    icon: snapshot.data == true
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: iconSize,
                                    onTap: _togglePlayPause,
                                  );
                                },
                              ),

                              _control(
                                  icon: Icons.forward_10,
                                  size: iconSize,
                                  onTap: _seekForward),

                              _control(
                                  icon: Icons.aspect_ratio,
                                  size: iconSize,
                                  onTap: _toggleFit),

                              _control(
                                  icon: Icons.fullscreen,
                                  size: iconSize,
                                  onTap: _toggleFullscreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ✅ Lock screen button (when locked)
                if (_isLocked)
                  Positioned(
                    top: padding,
                    left: padding,
                    child: _control(
                      icon: Icons.lock,
                      size: iconSize,
                      onTap: () {
                        setState(() {
                          _isLocked = false;
                          _showControls = true;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Reusable control button
  Widget _control({
    required IconData icon,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

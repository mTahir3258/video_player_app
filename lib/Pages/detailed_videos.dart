import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DetailedVideos extends StatefulWidget {
  final String videoPath;
  final String videoList;

  const DetailedVideos({
    super.key,
    required this.videoPath,
    required this.videoList,
  });

  @override
  State<DetailedVideos> createState() => _DetailedVideosState();
}

class _DetailedVideosState extends State<DetailedVideos> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isLocked = false;
  BoxFit _currentFit = BoxFit.contain;
  double _playbackSpeed = 1.0;
  bool _isFullscreen = false;
  bool _showControls = true;

  final List<double> _speedOptions = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.25,
    2.5,
    2.75,
    3.0,
  ];

  void _toggleControls() {
    if (_isLocked) return;
    setState(() => _showControls = !_showControls);
  }

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

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  Duration _displayTime(Duration realTime) {
    return Duration(
      milliseconds: (realTime.inMilliseconds / _playbackSpeed).round(),
    );
  }

  void _seekForward() {
    final pos = _player.state.position;
    _player.seek(pos + const Duration(seconds: 10));
  }

  void _seekBackward() {
    final pos = _player.state.position;
    _player.seek(
      pos - const Duration(seconds: 10) < Duration.zero
          ? Duration.zero
          : pos - const Duration(seconds: 10),
    );
  }

  void _toggleFit() {
    setState(() {
      _currentFit = _currentFit == BoxFit.contain
          ? BoxFit.cover
          : _currentFit == BoxFit.cover
          ? BoxFit.fill
          : BoxFit.contain;
    });
  }


void _playVideo() {
  _player.open(Media(widget.videoPath));
}

  @override
void initState() {
  super.initState();
  _player = Player();
  _videoController = VideoController(_player);
  _playVideo();
}



  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_player.state.playing)
      _player.pause();
    else
      _player.play();
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _speedOptions.map((speed) {
                  final isSelected = speed == _playbackSpeed;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _playbackSpeed = speed;
                        _player.setRate(speed);
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${speed}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
  final iconSize = base * 0.08;
  final padding = base * 0.025;

  return Scaffold(
    body: SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Video
            Positioned.fill(
              child: Video(
                controller: _videoController,
                fit: _currentFit,
                controls: null,
              ),
            ),

            // UI OVERLAY (shown only when _showControls)
            if (_showControls && !_isLocked) ...[
              // Top App Bar + Speed/Rotate
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: padding / 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Bar
                      Row(
                        children: [
                          IconButton(
                            iconSize: iconSize,
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              widget.videoList,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: base * 0.045,
                              ),
                            ),
                          ),
                        ],
                      ),

                  
                    ],
                  ),
                ),
              ),


                      // Speed + Fullscreen (right aligned)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                         padding: EdgeInsets.only(
                          top: media.padding.top + (base * 0.2),   // responsive top padding
                          left: base * 0.07,     
                         ),               
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: _showSpeedDialog,
                                child: Icon(
                                  Icons.speed,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              SizedBox(width: padding),
                              GestureDetector(
                                onTap: _toggleFullscreen,
                                child: Icon(
                                  _isFullscreen
                                      ? Icons.screen_rotation
                                      : Icons.screen_rotation,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                 

              // Bottom Controls
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Seek + Time
                      StreamBuilder<Duration>(
                        stream: _player.stream.position,
                        builder: (context, snapshot) {
                          final realPos =
                              snapshot.data ?? Duration.zero;
                          final realDur = _player.state.duration;

                          return Column(
                            children: [
                              Slider(
                                min: 0,
                                max: realDur.inMilliseconds.toDouble(),
                                value: realPos.inMilliseconds
                                    .clamp(0, realDur.inMilliseconds)
                                    .toDouble(),
                                onChanged: (v) =>
                                    _player.seek(Duration(milliseconds: v.toInt())),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: padding),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _format(_displayTime(realPos)),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      _format(_displayTime(realDur)),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: padding / 2),

                      // Play / Other Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _control(icon: Icons.lock_open, size: iconSize,
                              onTap: () {
                                setState(() {
                                  _isLocked = !_isLocked;
                                });
                              }),
                          _control(icon: Icons.arrow_back, size: iconSize,
                              onTap: _seekBackward),
                          StreamBuilder<bool>(
                            stream: _player.stream.playing,
                            builder: (ctx, snap) {
                              return _control(
                                icon: snap.data == true
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: iconSize,
                                onTap: _togglePlayPause,
                              );
                            },
                          ),
                          _control(icon: Icons.arrow_forward, size: iconSize,
                              onTap: _seekForward),
                          _control(icon: Icons.aspect_ratio,
                              size: iconSize, onTap: _toggleFit),
                          _control(
                            icon: _isFullscreen
                                ? Icons.fullscreen
                                : Icons.fullscreen,
                            size: iconSize,
                            onTap: _toggleFullscreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ], // end if _showControls
          ],
        ),
      ),
    ),
  );
}

  Widget _control({
    required IconData icon,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

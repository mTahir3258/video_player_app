import 'package:flutter/material.dart';
import '../model/video_playList.dart';

class PlaylistNotifier extends ValueNotifier<List<VideoPlaylist>> {
  PlaylistNotifier() : super([]);

  void addPlaylist(VideoPlaylist playlist) {
    value = [...value, playlist];
  }

  void removePlaylist(int index) {
    final list = [...value];
    list.removeAt(index);
    value = list;
  }
}

final playlistNotifier = PlaylistNotifier();

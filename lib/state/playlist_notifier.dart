import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../model/video_playList.dart';

class PlaylistNotifier extends ValueNotifier<List<VideoPlaylist>> {
 late final Box<VideoPlaylist> box ;

  PlaylistNotifier() : super([]) {
   box = Hive.box<VideoPlaylist>('playlistBox');
    loadPlaylists();
  }
  void loadPlaylists() {
    value = box.values.toList();
  }

  void addPlaylist(VideoPlaylist playlist) async{
  await  box.add(playlist);
    loadPlaylists();
  }

  void removePlaylist(VideoPlaylist playlist) async{
  await  box.delete(playlist.key);
    loadPlaylists();
  }
}

//Global  instance
final playlistNotifier = PlaylistNotifier();

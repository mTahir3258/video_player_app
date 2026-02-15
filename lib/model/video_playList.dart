import 'package:hive/hive.dart';
import 'package:player_app/model/system_video_model.dart';


@HiveType(typeId: 1)
class VideoPlaylist  extends HiveObject{
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<SystemVideo> videos;

  VideoPlaylist({
    required this.name,
    required this.videos,
  });
}

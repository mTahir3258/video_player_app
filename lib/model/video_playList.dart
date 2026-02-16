import 'package:hive/hive.dart';
import 'package:player_app/model/system_video_model.dart';
part 'video_playList.g.dart';


@HiveType(typeId: 0)
class VideoPlaylist  extends HiveObject{
  
  @HiveField(0)
  final String name;

  @HiveField(1)
   List<SystemVideo> videos;

  VideoPlaylist({
    required this.name,
    required this.videos,
  });
}

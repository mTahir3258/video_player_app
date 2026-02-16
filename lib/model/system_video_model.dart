import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';
part 'system_video_model.g.dart';

@HiveType(typeId: 1)
class SystemVideo extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  String name;

  @HiveField(2)
  int durationMillis; // store duration in milliseconds

  @HiveField(3)
  String? assetId;

  // ✅ Add a default constructor for Hive
  SystemVideo({
    this.path = '',
    this.name = '',
    Duration? duration,
    this.assetId,
  }) : durationMillis = duration?.inMilliseconds ?? 0;

  Duration get duration => Duration(milliseconds: durationMillis);
}

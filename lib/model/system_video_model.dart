import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';


@HiveType(typeId: 2)
class SystemVideo  extends HiveObject{
  @HiveType(typeId: 0)
  final String path;
  @HiveType(typeId: 1)
  final String name;
  @HiveField(2)
  final Duration? duration;
  @HiveField(3)
  final AssetEntity asset;

  SystemVideo({
    required this.path,
    required this.name,
    this.duration,
    required this.asset,
  });
}

import 'package:photo_manager/photo_manager.dart';
import '../model/system_video_model.dart';

class SystemVideoService {
  static Future<List<SystemVideo>> getVideos({String? folderPath}) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) return [];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<SystemVideo> videos = [];

      for (final album in albums) {
        if (folderPath != null && album.id != folderPath) continue;

        final media = await album.getAssetListPaged(
          page: 0,
          size: 200,
        );

        for (final asset in media) {
          final file = await asset.file;
          if (file != null) {
            videos.add(
              SystemVideo(
                path: file.path,
                name: file.path.split('/').last,
                duration: asset.videoDuration, // ✅ FIXED
                asset: asset,
              ),
            );
          }
        }
      }
      return videos;
    } catch (_) {
      return [];
    }
  }

  static Future<List<SystemVideo>> getVideosFromFolder(String folderName) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) return [];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<SystemVideo> videos = [];

      for (final album in albums) {
        if (album.name.toLowerCase() != folderName.toLowerCase()) continue;

        final media = await album.getAssetListPaged(
          page: 0,
          size: 200,
        );

        for (final asset in media) {
          final file = await asset.file;
          if (file != null) {
            videos.add(
              SystemVideo(
                path: file.path,
                name: file.path.split('/').last,
                duration: asset.videoDuration,
                asset: asset,
              ),
            );
          }
        }
      }
      return videos;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> deleteVideo(AssetEntity asset) async {
    try {
      final result = await PhotoManager.editor.deleteWithIds([asset.id]);
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

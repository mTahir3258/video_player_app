import 'package:photo_manager/photo_manager.dart';
import '../model/system_video_model.dart';

class SystemVideoService {

  // ✅ Get all videos (optionally from a specific folder)
  static Future<List<SystemVideo>> getVideos({String? folderPath}) async {
    try {
      // ✅ Ask user for storage/media permission
      final permission = await PhotoManager.requestPermissionExtend();

      // ❌ If permission denied → return empty list
      if (!permission.isAuth) return [];

      // ✅ Get all video albums/folders
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      // ✅ List to store videos
      List<SystemVideo> videos = [];

      // ✅ Loop through albums
      for (final album in albums) {

        // ✅ If folderPath provided → filter album
        if (folderPath != null && album.id != folderPath) continue;

        // ✅ Load videos from album (first 200 items)
        final media = await album.getAssetListPaged(
          page: 0,
          size: 200,
        );

        // ✅ Loop through videos
        for (final asset in media) {

          // ✅ Convert asset → file
          final file = await asset.file;

          // ✅ If file exists → add to list
          if (file != null) {
            videos.add(
              SystemVideo(
                path: file.path,                         // video path
                name: file.path.split('/').last,          // video name
                duration: asset.videoDuration,            // video duration
                assetId: asset.id,                        // asset id
              ),
            );
          }
        }
      }

      // ✅ Return final video list
      return videos;

    } catch (_) {
      // ❌ If error → return empty list
      return [];
    }
  }

  // ✅ Get videos from folder name
  static Future<List<SystemVideo>> getVideosFromFolder(String folderName) async {
    try {
      // ✅ Request permission
      final permission = await PhotoManager.requestPermissionExtend();

      // ❌ If denied → empty list
      if (!permission.isAuth) return [];

      // ✅ Get video albums
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<SystemVideo> videos = [];

      // ✅ Find matching folder
      for (final album in albums) {

        // ✅ Compare folder name (case insensitive)
        if (album.name.toLowerCase() != folderName.toLowerCase()) continue;

        // ✅ Load videos
        final media = await album.getAssetListPaged(
          page: 0,
          size: 200,
        );

        // ✅ Loop assets
        for (final asset in media) {
          final file = await asset.file;

          if (file != null) {
            videos.add(
              SystemVideo(
                path: file.path,
                name: file.path.split('/').last,
                duration: asset.videoDuration,
                assetId: asset.id,
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

  // ✅ Delete a video using AssetEntity
  static Future<bool> deleteVideo(AssetEntity asset) async {
    try {
      // ✅ Delete video by id
      final result = await PhotoManager.editor.deleteWithIds([asset.id]);

      // ✅ If deletion successful → result not empty
      return result.isNotEmpty;

    } catch (_) {
      // ❌ If error → deletion failed
      return false;
    }
  }
}

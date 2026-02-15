import 'package:permission_handler/permission_handler.dart';

// This function asks the user for video access permission
Future<bool> requestVideoPermission() async {
  
    // Check if video permission is already allowed
  if (await Permission.videos.isGranted) return true;
    // Ask the user for video permission
  final status = await Permission.videos.request();
    // Return true if permission is allowed, otherwise false
  return status.isGranted;

}

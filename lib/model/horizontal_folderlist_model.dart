import 'package:flutter/widgets.dart';


/// Model class used to represent a folder item
/// in a horizontal folder list UI.
class HorizontalFolderlistModel {

    /// Icon that represents the folder (e.g. Icons.folder)
  final IconData iconsName;

    /// Name/label of the folder shown to the user
  final String folderName;

  /// Constructor for [HorizontalFolderlistModel]
  /// 
  /// Both [iconsName] and [folderName] are required
  /// to ensure every folder item has an icon and a name.
  HorizontalFolderlistModel({
    required this.iconsName,
    required this.folderName,
  });
}

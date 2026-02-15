import 'package:flutter/material.dart';

/// This class is used to store video folder information
class VideoFolder {
    /// Icon shown for the video folder
  final IconData icon;
    /// Main name of the folder
  final String title;
    /// Extra information about the folder (like number of videos)
  final String subtitle;

 /// Constructor to create a VideoFolder object
  /// All values must be provided
  VideoFolder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

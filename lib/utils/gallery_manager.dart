import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/configs/configs.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

class GAPManager {
  static GalleryConfig _config = const GalleryConfig();
  static GalleryConfig get config => _config;
  static SlideSheetConfig get slideSheetConfig => _config.slideSheetConfig;
  static CameraConfig get cameraConfig => _config.cameraConfig;
  static ColorScheme get colorScheme => _config.colorScheme;
  static TextTheme get textTheme => _config.textTheme;

  static GalleryController _controller = GalleryController();
  static GalleryController get controller => _controller;
  static AlbumListController get albumListController => _controller.albumListController;
  static SlideSheetController get slideSheetController => _controller.slideSheetController;
  static bool get isFullScreenMode => _controller.slideSheetKey.currentState == null;

  static updateConfig(GalleryConfig config) {
    _config = config;
  }

  static updateController(GalleryController controller) {
    _controller = controller;
  }
}

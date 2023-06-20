import 'package:gallery_asset_picker/configs/configs.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';

class GalleryManager {
  static GalleryConfig _config = const GalleryConfig();
  static GalleryConfig get config => _config;

  static GalleryController _controller = GalleryController();
  static GalleryController get controller => _controller;

  static updateConfig(GalleryConfig config) {
    _config = config;
  }

  static updateController(GalleryController controller) {
    _controller = controller;
  }
}

library gallery_asset_picker;

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/configs/configs.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/features.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_full_screen_page.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:gallery_asset_picker/configs/configs.dart';
export 'package:gallery_asset_picker/entities/gallery_asset.dart';
export 'package:gallery_asset_picker/features/features.dart';
export 'package:photo_manager/photo_manager.dart';

class GalleryAssetPicker {
  static bool _isInitialize = false;

  static initialize(GalleryConfig config) {
    if (!_isInitialize) {
      _isInitialize = true;
      GAPManager.updateConfig(config);
    }
  }

  static Future<List<GalleryAsset>> pick(BuildContext context, {int? maxCount, RequestType? requestType}) async {
    if (GAPManager.isFullScreenMode) {
      final controller = GalleryController();
      GAPManager.updateController(controller);
      NavigatorUtils.of(context)
          .push(SlidingPageRoute(child: GalleryFullScreenPage(controller: controller)))
          .then((value) => SystemUtils.showStatusBar());
    } else {
      FocusScope.of(context).unfocus();
      GAPManager.controller.slideSheetController.open();
    }

    return GAPManager.controller.startSelection(maxCount: maxCount, requestType: requestType);
  }
}

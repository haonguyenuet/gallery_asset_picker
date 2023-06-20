library gallery_asset_picker;

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/configs/configs.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/features.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:gallery_asset_picker/configs/configs.dart';
export 'package:gallery_asset_picker/entities/gallery_asset.dart';
export 'package:gallery_asset_picker/features/features.dart';
export 'package:photo_manager/photo_manager.dart';

class GalleryAssetPicker {
  static configure(GalleryConfig config) {
    GalleryManager.updateConfig(config);
  }

  static Future<List<GalleryAsset>> pick(BuildContext context, {int? maxCount, RequestType? requestType}) async {
    if (GalleryManager.controller.isFullScreenMode) {
      GalleryManager.updateController(GalleryController());
      NavigatorUtils.of(context)
          .push(SlidingPageRoute(child: const GalleryView()))
          .then((value) => SystemUtils.showStatusBar());
    } else {
      FocusScope.of(context).unfocus();
      GalleryManager.controller.slideSheetController.open();
    }

    return GalleryManager.controller.startSelection(maxCount: maxCount, requestType: requestType);
  }
}

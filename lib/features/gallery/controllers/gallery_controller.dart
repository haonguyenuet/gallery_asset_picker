import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/src/camera_view.dart';
import 'package:gallery_asset_picker/features/camera/src/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/utils/system_utils.dart';

class GalleryController extends ValueNotifier<Gallery> {
  GalleryController({GallerySetting? settings}) : super(Gallery.none()) {
    updateSettings(settings);
  }

  late Completer<List<GalleryAsset>> _selectionTask;
  final GlobalKey slidablePanelKey = GlobalKey();
  final SlidablePanelController slidablePanelController = SlidablePanelController();
  final AlbumListController albumListController = AlbumListController();
  GallerySetting _setting = const GallerySetting();

  GallerySetting get setting => _setting;
  SlidablePanelSetting get slidablePanelSetting => setting.slidablePanelSetting;
  bool get isFullScreenMode => slidablePanelKey.currentState == null;
  bool get reachedMaximumLimit => value.selectedAssets.length == setting.maxCount;
  bool get singleSelection => setting.maxCount == 1;

  void updateSettings(GallerySetting? setting) {
    _setting = setting ?? const GallerySetting();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.setting.selectedAssets.isNotEmpty) {
        value = value.copyWith(selectedAssets: this.setting.selectedAssets);
      }
    });
  }

  void toggleAlbumListVisibility() {
    value = value.copyWith(isAlbumVisible: !value.isAlbumVisible);
    slidablePanelController.gestureEnabled = !value.isAlbumVisible;
  }

  void select(GalleryAsset asset) {
    if (singleSelection) {
      setting.onChanged?.call(asset, false);
      value = value.copyWith(selectedAssets: [asset]);
      return;
    }

    final assets = List.of(value.selectedAssets);
    final isSelected = assets.contains(asset);
    if (isSelected) {
      assets.remove(asset);
      setting.onChanged?.call(asset, isSelected);
      value = value.copyWith(selectedAssets: assets);
    } else if (!reachedMaximumLimit) {
      assets.add(asset);
      setting.onChanged?.call(asset, isSelected);
      value = value.copyWith(selectedAssets: assets);
    }

    if (reachedMaximumLimit) {
      return setting.onReachMaximum?.call();
    }
  }

  void clearSelection() {
    value = value.copyWith(selectedAssets: []);
  }

  List<GalleryAsset> completeSelection() {
    final assets = value.selectedAssets;
    value = Gallery.none();
    _selectionTask.complete(assets);
    return assets;
  }

  Future<List<GalleryAsset>> open(BuildContext context) async {
    _selectionTask = Completer<List<GalleryAsset>>();

    if (isFullScreenMode) {
      NavigatorUtils.of(context)
          .push(SlidingPageRoute(child: GalleryPage(controller: this)))
          .then((value) => SystemUtils.showStatusBar());
    } else {
      FocusScope.of(context).unfocus();
      slidablePanelController.open();
    }

    return _selectionTask.future;
  }

  void close(BuildContext context) {
    if (isFullScreenMode) {
      NavigatorUtils.of(context).pop();
    } else {
      slidablePanelController.close();
    }
  }

  Future<GalleryAsset?> openCamera(BuildContext context) async {
    final navigator = NavigatorUtils.of(context);

    final route = SlidingPageRoute<List<GalleryAsset>>(
      child: CameraView(
        controller: XCameraController(),
        setting: setting.cameraSetting,
      ),
      setting: const SlidingRouteSettings(
        start: TransitionFrom.leftToRight,
        reverse: TransitionFrom.rightToLeft,
      ),
    );
    return null;
  }

  @override
  void dispose() {
    albumListController.dispose();
    slidablePanelController.dispose();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/entities/gallery.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

class GalleryController extends ValueNotifier<Gallery> {
  GalleryController({GallerySetting? settings}) : super(Gallery.none()) {
    updateSettings(settings);
  }

  late Completer<List<GalleryAsset>> _selectionTask;

  final GlobalKey slidablePanelKey = GlobalKey();
  final SlidablePanelController slidablePanelController = SlidablePanelController();
  final ValueNotifier<bool> albumVisibility = ValueNotifier(false);
  GallerySetting _setting = const GallerySetting();

  GallerySetting get setting => _setting;
  SlidablePanelSetting get slidablePanelSetting => setting.slidablePanelSetting;
  bool get isFullScreenMode => slidablePanelKey.currentState == null;
  bool get reachedMaximumLimit => value.selectedAssets.length == setting.maxCount;
  bool get singleSelection =>
      setting.selectionMode == SelectionMode.actionBased ? !value.allowMultiple : setting.maxCount == 1;

  void updateSettings(GallerySetting? setting) {
    _setting = setting ?? const GallerySetting();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.setting.selectedAssets.isNotEmpty) {
        value = value.copyWith(selectedAssets: this.setting.selectedAssets);
      }
    });
  }

  void setAlbumVisibility({required bool visible}) {
    slidablePanelController.gestureEnabled = !visible;
    albumVisibility.value = visible;
    value = value.copyWith(isAlbumVisible: visible);
  }

  void toggleMultiSelection() {
    value = value.copyWith(allowMultiple: !value.allowMultiple);
  }

  void select(GalleryAsset asset) {
    final assets = List.of(value.selectedAssets);

    if (reachedMaximumLimit) {
      assets.remove(asset);
      value = value.copyWith(selectedAssets: assets);
      return setting.onReachMaximum?.call();
    }

    if (singleSelection) {
      setting.onChanged?.call(asset, false);
      value = value.copyWith(selectedAssets: [asset]);
      return;
    }

    final isSelected = assets.contains(asset);
    if (isSelected) {
      assets.remove(asset);
    } else {
      assets.add(asset);
    }
    setting.onChanged?.call(asset, isSelected);
    value = value.copyWith(selectedAssets: assets);
  }

  void clearSelection() {
    value = value.copyWith(selectedAssets: []);
  }

  Future<List<GalleryAsset>> pick(
    BuildContext context, {
    SlidingRouteSettings? routeSetting,
  }) async {
    _selectionTask = Completer<List<GalleryAsset>>();

    if (setting != null) {
      updateSettings(setting);
    }
    if (isFullScreenMode) {
      Navigator.of(context).push(SlidingPageRoute(
        child: GalleryPage(controller: this),
        setting: routeSetting ?? const SlidingRouteSettings(settings: RouteSettings(name: 'GalleryView')),
      ));
    } else {
      FocusScope.of(context).unfocus();
      slidablePanelController.open();
    }

    return _selectionTask.future;
  }

  List<GalleryAsset> completeSelection() {
    final assets = value.selectedAssets;
    value = const Gallery();
    _selectionTask.complete(assets);
    return assets;
  }

  @override
  void dispose() {
    slidablePanelController.dispose();
    albumVisibility.dispose();
    super.dispose();
  }
}

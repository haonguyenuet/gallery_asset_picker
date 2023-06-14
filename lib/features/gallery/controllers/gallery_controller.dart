import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modern_media_picker/features/gallery/gallery_view.dart';

import '../../../entities/asset_entity_plus.dart';
import '../../../widgets/widgets.dart';
import '../entities/gallery_entity.dart';
import '../entities/gallery_settings.dart';

class GalleryController extends ValueNotifier<GalleryEntity> {
  GalleryController({GallerySetting? settings}) : super(GalleryEntity.none()) {
    updateSettings(settings);
  }

  late Completer<List<AssetEntityPlus>> _selectionTask;

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

  void toogleMultiSelection() {
    value = value.copyWith(allowMultiple: !value.allowMultiple);
  }

  void select(AssetEntityPlus asset) {
    if (reachedMaximumLimit) {
      return setting.onReachMaximum?.call();
    }

    if (singleSelection) {
      setting.onChanged?.call(asset, false);
      value = value.copyWith(selectedAssets: [asset]);
      return;
    }

    final assets = List.of(value.selectedAssets);
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

  Future<List<AssetEntityPlus>> pick(
    BuildContext context, {
    GallerySetting? setting,
    SlidingRouteSettings? routeSetting,
  }) async {
    _selectionTask = Completer<List<AssetEntityPlus>>();

    if (setting != null) {
      updateSettings(setting);
    }
    if (isFullScreenMode) {
      Navigator.of(context).push(
        SlidingPageRoute(
          builder: GalleryView(controller: this, setting: setting),
          setting: routeSetting ?? const SlidingRouteSettings(settings: RouteSettings(name: GalleryView.name)),
        ),
      );
    } else {
      FocusScope.of(context).unfocus();
      slidablePanelController.open();
    }

    return _selectionTask.future;
  }

  List<AssetEntityPlus> completeSelection() {
    final assets = value.selectedAssets;
    value = const GalleryEntity();
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

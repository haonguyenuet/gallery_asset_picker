import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modern_media_picker/features/gallery/gallery_view.dart';
import 'package:modern_media_picker/widgets/animations/page_route.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../../../utils/ui_handler.dart';
import '../../../widgets/widgets.dart';
import '../entities/gallery_entity.dart';
import '../entities/gallery_settings.dart';
import 'albums_controller.dart';

///
/// Gallery controller
class GalleryController extends ValueNotifier<GalleryEntity> {
  ///
  /// Gallery controller constructor
  GalleryController()
      : slidablePanelKey = GlobalKey<SlidablePanelState>(),
        panelController = PanelController(),
        albumVisibility = ValueNotifier(false),
        super(const GalleryEntity()) {
    initSettings();
  }

  final GlobalKey<SlidablePanelState> slidablePanelKey;
  final PanelController panelController;
  final ValueNotifier<bool> albumVisibility;

  late GallerySetting setting;
  late PanelSetting panelSetting;
  // late CameraSetting _cameraSetting;
  late Completer<List<AssetEntityPlus>> _pickCompleter;

  bool get fullScreenMode => slidablePanelKey.currentState == null;
  bool get reachedMaximumLimit => value.selectedAssets.length == setting.maxCount;
  bool get singleSelection =>
      setting.selectionMode == SelectionMode.actionBased ? !value.enableMultiSelection : setting.maxCount == 1;

  void initSettings({GallerySetting? setting}) {
    this.setting = setting ?? const GallerySetting();
    panelSetting = this.setting.panelSetting;
    // _cameraSetting = _setting.cameraSetting ?? const CameraSetting();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.setting.selectedAssets.isNotEmpty) {
        value = value.copyWith(selectedAssets: this.setting.selectedAssets);
      }
    });
  }

  void setAlbumVisibility({required bool visible}) {
    panelController.isGestureEnabled = !visible;
    albumVisibility.value = visible;
    value = value.copyWith(isAlbumVisible: visible);
  }

  void toogleMultiSelection() {
    value = value.copyWith(
      enableMultiSelection: !value.enableMultiSelection,
    );
  }

  void select(BuildContext context, AssetEntityPlus asset) {
    if (reachedMaximumLimit) {
      return setting.onReachMaximum?.call();
    }

    if (singleSelection) {
      setting.onChanged?.call(asset, false);
      completeSelection(context, assets: [asset]);
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

  // ///
  // /// Open camera from [GalleryView]
  // Future<AssetEntityPlus?> openCamera(BuildContext context) async {
  //   final uiHandler = UIHandler.of(context);

  //   final route = SlidingPageRoute<List<AssetEntityPlus>>(
  //     builder: CameraView(
  //       setting: _cameraSetting.copyWith(enableGallery: false),
  //       editorSetting: _cameraTextEditorSetting,
  //       photoEditorSetting: _cameraPhotoEditorSetting,
  //     ),
  //     setting: const CustomRouteSetting(
  //       start: TransitionFrom.leftToRight,
  //       reverse: TransitionFrom.rightToLeft,
  //     ),
  //   );

  //   if (fullScreenMode) {
  //     final list = await uiHandler.push(route);
  //     await UIHandler.showStatusBar();
  //     if (list?.isNotEmpty ?? false) {
  //       final ety = list!.first;
  //       _onChanged?.call(ety, false);
  //       if (!uiHandler.mounted) return null;
  //       completeTask(context, assets: [...value.selectedEntities, ety]);
  //       return ety;
  //     }
  //   } else {
  //     _panelController.minimizePanel();
  //     final list = await Navigator.of(context).push(route);
  //     await UIHandler.showStatusBar();
  //     if (list?.isNotEmpty ?? false) {
  //       final ety = list!.first;
  //       // Camera was open on selection mode? then complete task
  //       // else select item
  //       if (singleSelection) {
  //         if (!uiHandler.mounted) return null;
  //         completeTask(context, assets: [ety]);
  //       } else {
  //         if (!uiHandler.mounted) return null;
  //         select(context, ety);
  //       }
  //       return ety;
  //     }
  //   }
  //   return null;
  // }

  ///
  /// Handle picking process for slidable gallery using completer
  Future<List<AssetEntityPlus>> _collapsableGallery(BuildContext context) {
    _pickCompleter = Completer<List<AssetEntityPlus>>();
    panelController.open();
    FocusScope.of(context).unfocus();
    return _pickCompleter.future;
  }

  // ===================== PUBLIC ==========================  ///
  List<AssetEntityPlus> completeSelection(BuildContext context, {List<AssetEntityPlus>? assets}) {
    final _assets = assets ?? value.selectedAssets;

    if (fullScreenMode) {
      UIHandler.of(context).pop(_assets);
      return _assets;
    }

    panelController.close();
    value = const GalleryEntity();
    _pickCompleter.complete(_assets);
    return _assets;
  }

  void clearSelection() {
    value = value.copyWith(selectedAssets: []);
  }

  Future<List<AssetEntityPlus>> pick(
    BuildContext context, {
    GallerySetting? setting,
    SlidingRouteSettings? routeSetting,
  }) async {
    if (setting != null) {
      initSettings(setting: setting);
    }

    if (fullScreenMode) {
      final assets = await pickAssets(context, controller: this, setting: setting, routeSetting: routeSetting);
      await UIHandler.showStatusBar();
      return assets ?? [];
    }

    return _collapsableGallery(context);
  }

  @override
  void dispose() {
    panelController.dispose();
    albumVisibility.dispose();
    super.dispose();
  }
}

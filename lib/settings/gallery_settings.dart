import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:photo_manager/photo_manager.dart';

/// Available multiselection mode for gallery
enum SelectionMode {
  /// maximumCount provided in [GallerySetting] will be use to determine
  /// selection mode.
  countBased,

  /// Multiselection toogler widget will be used to determine selection mode.
  /// maximumCount provided in [GallerySetting] will be preserved
  actionBased,
}

class GallerySetting {
  const GallerySetting({
    this.selectedAssets = const [],
    this.requestType = RequestType.all,
    this.maxCount = 50,
    this.selectionMode = SelectionMode.countBased,
    this.albumTitle = StringConst.ALL_ALBUMS,
    this.albumSubtitle = 'Select Media',
    this.enableCamera = true,
    this.crossAxisCount = 3,
    this.slidablePanelSetting = const SlidablePanelSetting(),
    this.onChanged,
    this.onReachMaximum,
    this.closingDialogBuilder,
    this.theme,
  });

  ///
  /// Previously selected entities
  final List<GalleryAsset> selectedAssets;

  ///
  /// Type of media e.g, image, video, audio, other
  /// Default is [RequestType.all]
  final RequestType requestType;

  ///
  /// Total media allowed to select. Default is 50
  final int maxCount;

  ///
  /// Multiselection mode, default is [SelectionMode.countBased]
  final SelectionMode selectionMode;

  ///
  /// Album name for all photos, default is set to "All Photos"
  final String albumTitle;

  ///
  /// String displayed below album name. Default : 'Select media'
  final String albumSubtitle;

  ///
  /// Set false to hide camera from gallery view
  final bool enableCamera;

  ///
  /// Gallery grid cross axis count. Default is 3
  final int crossAxisCount;

  ///
  /// Gallery slidable panel setting
  final SlidablePanelSetting slidablePanelSetting;

  ///
  /// Camera setting
  // final CameraSetting? cameraSetting;

  ///
  /// On select or remove asset
  final Function(GalleryAsset asset, bool removed)? onChanged;

  ///
  /// On select maximum count
  final Function()? onReachMaximum;

  ///
  /// Alert dialog when closing with selected assets
  final Widget Function()? closingDialogBuilder;

  ///
  /// Button Style
  final ThemeData? theme;

  ///
  /// Helper function to copy its properties
  GallerySetting copyWith({
    List<GalleryAsset>? selectedAssets,
    RequestType? requestType,
    int? maximumCount,
    SelectionMode? selectionMode,
    String? albumTitle,
    String? albumSubtitle,
    bool? enableCamera,
    int? crossAxisCount,
    SlidablePanelSetting? slidablePanelSetting,
    // CameraSetting? cameraSetting,
    Function(GalleryAsset asset, bool removed)? onChanged,
    Function()? onReachMaximum,
    Widget Function()? closingDialogBuilder,
    ThemeData? theme,
  }) {
    return GallerySetting(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      requestType: requestType ?? this.requestType,
      maxCount: maximumCount ?? this.maxCount,
      selectionMode: selectionMode ?? this.selectionMode,
      albumTitle: albumTitle ?? this.albumTitle,
      albumSubtitle: albumSubtitle ?? this.albumSubtitle,
      enableCamera: enableCamera ?? this.enableCamera,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      slidablePanelSetting: slidablePanelSetting ?? this.slidablePanelSetting,
      // cameraSetting: cameraSetting ?? this.cameraSetting,
      onChanged: onChanged ?? this.onChanged,
      onReachMaximum: onReachMaximum ?? this.onReachMaximum,
      closingDialogBuilder: closingDialogBuilder ?? this.closingDialogBuilder,
      theme: theme ?? this.theme,
    );
  }
}

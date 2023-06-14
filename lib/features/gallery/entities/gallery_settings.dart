import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../../../widgets/slidable_panel/slidable_panel.dart';

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
    this.albumTitle = 'All Photos',
    this.albumSubtitle = 'Select Media',
    this.enableCamera = true,
    this.crossAxisCount = 3,
    this.panelSetting = const PanelSetting(),
    this.onChanged,
    this.onReachMaximum,
  });

  ///
  /// Previously selected entities
  final List<AssetEntityPlus> selectedAssets;

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
  final PanelSetting panelSetting;

  ///
  /// Camera setting
  // final CameraSetting? cameraSetting;

  ///
  /// On select or remove asset
  final Function(AssetEntityPlus asset, bool removed)? onChanged;

  ///
  /// On select maximum count
  final Function()? onReachMaximum;

  ///
  /// Helper function to copy its properties
  GallerySetting copyWith({
    List<AssetEntityPlus>? selectedEntities,
    RequestType? requestType,
    int? maximumCount,
    SelectionMode? selectionMode,
    String? albumTitle,
    String? albumSubtitle,
    bool? enableCamera,
    int? crossAxisCount,
    PanelSetting? panelSetting,
    // CameraSetting? cameraSetting,
    Function(AssetEntityPlus asset, bool removed)? onChanged,
    Function()? onReachMaximum,
  }) {
    return GallerySetting(
      selectedAssets: selectedEntities ?? this.selectedAssets,
      requestType: requestType ?? this.requestType,
      maxCount: maximumCount ?? this.maxCount,
      selectionMode: selectionMode ?? this.selectionMode,
      albumTitle: albumTitle ?? this.albumTitle,
      albumSubtitle: albumSubtitle ?? this.albumSubtitle,
      enableCamera: enableCamera ?? this.enableCamera,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      panelSetting: panelSetting ?? this.panelSetting,
      // cameraSetting: cameraSetting ?? this.cameraSetting,
      onChanged: onChanged ?? this.onChanged,
      onReachMaximum: onReachMaximum ?? this.onReachMaximum,
    );
  }
}

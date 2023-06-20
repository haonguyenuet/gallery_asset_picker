import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/configs/camera_config.dart';
import 'package:gallery_asset_picker/configs/slide_sheet_config.dart';
import 'package:gallery_asset_picker/utils/const.dart';

class GalleryConfig {
  const GalleryConfig({
    this.albumTitle = StringConst.ALL_PHOTOS,
    this.enableCamera = true,
    this.crossAxisCount = 3,
    this.slideSheetConfig = const SlideSheetConfig(),
    this.cameraConfig = const CameraConfig(),
    this.onReachMaximum,
    this.closingDialogBuilder,
    this.textTheme = const TextTheme(
      bodyMedium: TextStyle(fontSize: 16),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    this.colorScheme = const ColorScheme.light(),
    this.overlayStyle = SystemUiOverlayStyle.dark,
  });

  ///
  /// Album name for all photos, default is set to "All Photos"
  final String albumTitle;

  ///
  /// Set false to hide camera from gallery view
  final bool enableCamera;

  ///
  /// Gallery grid cross axis count. Default is 3
  final int crossAxisCount;

  ///
  /// Gallery slidable sheet config
  final SlideSheetConfig slideSheetConfig;

  ///
  /// Camera config
  final CameraConfig cameraConfig;

  ///
  /// On select maximum count
  final Function()? onReachMaximum;

  ///
  /// Alert dialog when closing with selected assets
  final Widget Function()? closingDialogBuilder;

  ///
  /// Color Scheme
  final TextTheme textTheme;

  ///
  /// Color Scheme
  final ColorScheme colorScheme;

  ///
  /// Overlay Style
  final SystemUiOverlayStyle overlayStyle;

  ///
  /// Helper function to copy its properties
  GalleryConfig copyWith({
    String? albumTitle,
    bool? enableCamera,
    int? crossAxisCount,
    SlideSheetConfig? slideSheetConfig,
    CameraConfig? cameraConfig,
    Function()? onReachMaximum,
    Widget Function()? closingDialogBuilder,
    TextTheme? textTheme,
    ColorScheme? colorScheme,
    SystemUiOverlayStyle? overlayStyle,
  }) {
    return GalleryConfig(
      albumTitle: albumTitle ?? this.albumTitle,
      enableCamera: enableCamera ?? this.enableCamera,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      slideSheetConfig: slideSheetConfig ?? this.slideSheetConfig,
      cameraConfig: cameraConfig ?? this.cameraConfig,
      onReachMaximum: onReachMaximum ?? this.onReachMaximum,
      closingDialogBuilder: closingDialogBuilder ?? this.closingDialogBuilder,
      colorScheme: colorScheme ?? this.colorScheme,
      overlayStyle: overlayStyle ?? this.overlayStyle,
    );
  }
}

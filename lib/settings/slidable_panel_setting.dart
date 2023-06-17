import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlidablePanelSetting {
  const SlidablePanelSetting({
    this.maxHeight,
    this.minHeight,
    this.toolbarHeight = 48,
    this.handleBarHeight = 20.0,
    this.snapingPoint = 0.4,
    this.headerBackground = Colors.black,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.overlayStyle = SystemUiOverlayStyle.light,
  }) : assert(
          snapingPoint >= 0.0 && snapingPoint <= 1.0,
          '[snapingPoint] value must be between 1.0 and 0.0',
        );

  /// Panel maximum height
  ///
  /// mediaQuery = MediaQuery.of(context)
  /// Default: mediaQuery.size.height -  mediaQuery.padding.top
  final double? maxHeight;

  /// Panel minimum height
  /// Default: 40% of [maxHeight]
  final double? minHeight;

  /// Panel toolbar height
  ///
  /// Default:  [kToolbarHeight]
  final double toolbarHeight;

  /// Panel thumb handler height, which will be used to drag the panel
  ///
  /// Default: 25.0 px
  final double handleBarHeight;

  /// Point from where panel will start fling animation to snap it's height
  /// to [minHeight] or [maxHeight]
  /// Value must be between 0.0 - 1.0
  /// Default: 0.4
  final double snapingPoint;

  /// Background color for panel header,
  /// Default: [Colors.black]
  final Color headerBackground;

  /// Background color for panel,
  /// Default: [Colors.black]
  final Color foregroundColor;

  /// If [headerBackground] is missing [backgroundColor] will be applied
  /// If [foregroundColor] is missing [backgroundColor] will be applied
  ///
  /// Default: [Colors.black]
  final Color backgroundColor;

  final SystemUiOverlayStyle overlayStyle;

  /// Header  height
  double get headerHeight => handleBarHeight + toolbarHeight;

  /// Album  height
  double get albumHeight => maxHeight! - headerHeight;

  SlidablePanelSetting copyWith({
    double? maxHeight,
    double? minHeight,
    double? toolbarHeight,
    double? handleBarHeight,
    double? snapingPoint,
    Color? headerBackground,
    Color? foregroundColor,
    Color? backgroundColor,
    SystemUiOverlayStyle? overlayStyle,
  }) {
    return SlidablePanelSetting(
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      handleBarHeight: handleBarHeight ?? this.handleBarHeight,
      snapingPoint: snapingPoint ?? this.snapingPoint,
      headerBackground: headerBackground ?? this.headerBackground,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayStyle: overlayStyle ?? this.overlayStyle,
    );
  }
}

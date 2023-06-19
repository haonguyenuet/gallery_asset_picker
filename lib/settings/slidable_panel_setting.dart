import 'package:flutter/material.dart';

class SlidablePanelSetting {
  const SlidablePanelSetting({
    this.maxHeight,
    this.minHeight,
    this.toolbarHeight = 48,
    this.handleBarHeight = 20.0,
    this.snapingPoint = 0.4,
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
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return SlidablePanelSetting(
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      handleBarHeight: handleBarHeight ?? this.handleBarHeight,
      snapingPoint: snapingPoint ?? this.snapingPoint,
    );
  }
}

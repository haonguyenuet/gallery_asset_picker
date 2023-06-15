import 'package:flutter/material.dart';

import 'slidable_panel.dart';

const _defaultMin = 0.45;

class SlidablePanelSettingBuilder extends StatelessWidget {
  const SlidablePanelSettingBuilder({
    Key? key,
    required this.setting,
    required this.builder,
  }) : super(key: key);

  final SlidablePanelSetting? setting;
  final Widget Function(SlidablePanelSetting panelSetting) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final size = constraints.biggest;
        final isFullScreen = size.height == mediaQuery.size.height;
        final panelSetting = setting ?? const SlidablePanelSetting();
        final _maxHeight = panelSetting.maxHeight ?? size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final _minHeight = panelSetting.minHeight ?? _maxHeight * _defaultMin;
        final _setting = panelSetting.copyWith(
          maxHeight: _maxHeight,
          minHeight: _minHeight,
        );
        return builder(_setting);
      },
    );
  }
}
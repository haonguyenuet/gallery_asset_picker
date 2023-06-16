import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';

const _defaultMin = 0.4;

class SlidablePanelSafeBuilder extends StatelessWidget {
  const SlidablePanelSafeBuilder({
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

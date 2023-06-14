import 'package:flutter/material.dart';

import '../../../widgets/slidable_panel/slidable_panel.dart';

const _defaultMin = 0.45;

class PanelSettingBuilder extends StatelessWidget {
  const PanelSettingBuilder({
    Key? key,
    required this.setting,
    required this.builder,
  }) : super(key: key);

  final PanelSetting? setting;
  final Widget Function(PanelSetting panelSetting) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final size = constraints.biggest;
        final isFullScreen = size.height == mediaQuery.size.height;
        final panelSetting = setting ?? const PanelSetting();
        final _panelMaxHeight = panelSetting.maxHeight ?? size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final _panelMinHeight = panelSetting.minHeight ?? _panelMaxHeight * _defaultMin;
        final _setting = panelSetting.copyWith(
          maxHeight: _panelMaxHeight,
          minHeight: _panelMinHeight,
        );
        return builder(_setting);
      },
    );
  }
}

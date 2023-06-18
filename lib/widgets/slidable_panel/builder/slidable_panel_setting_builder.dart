import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';

class SlidablePanelSafeBuilder extends StatefulWidget {
  const SlidablePanelSafeBuilder({
    Key? key,
    required this.setting,
    required this.builder,
  }) : super(key: key);

  final SlidablePanelSetting? setting;
  final Widget Function(SlidablePanelSetting panelSetting) builder;

  @override
  State<SlidablePanelSafeBuilder> createState() => _SlidablePanelSafeBuilderState();
}

class _SlidablePanelSafeBuilderState extends State<SlidablePanelSafeBuilder> {
  double _keyboardHeight = 0;
  double _lastBottomInset = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final size = constraints.biggest;
        final isFullScreen = size.height == mediaQuery.size.height;
        final panelSetting = widget.setting ?? const SlidablePanelSetting();
        _calcKeyboardHeight();

        final _maxHeight = panelSetting.maxHeight ?? size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final _minHeight = _keyboardHeight > 0 ? _keyboardHeight : _maxHeight * 0.4;
        final _setting = panelSetting.copyWith(
          maxHeight: _maxHeight,
          minHeight: _minHeight,
        );
        return widget.builder(_setting);
      },
    );
  }

  void _calcKeyboardHeight() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    /// When keyboard is hidden
    if (bottomInset == 0) {
      _lastBottomInset = 0;
    }

    /// When keyboard is showing
    if (bottomInset > _lastBottomInset) {
      _lastBottomInset = bottomInset;
      _keyboardHeight = _lastBottomInset;
    }
  }
}

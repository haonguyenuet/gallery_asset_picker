import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/configs/configs.dart';

class SlideSheetSafeSize extends StatefulWidget {
  const SlideSheetSafeSize({
    Key? key,
    required this.config,
    required this.builder,
  }) : super(key: key);

  final SlideSheetConfig? config;
  final Widget Function(SlideSheetConfig safeConfig) builder;

  @override
  State<SlideSheetSafeSize> createState() => _SlideSheetSafeSizeState();
}

class _SlideSheetSafeSizeState extends State<SlideSheetSafeSize> {
  double _keyboardHeight = 0;
  double _lastBottomInset = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final size = constraints.biggest;
        final isFullScreen = size.height == mediaQuery.size.height;
        final panelConfig = widget.config ?? const SlideSheetConfig();
        _calcKeyboardHeight();

        final _maxHeight = panelConfig.maxHeight ?? size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final _minHeight = _keyboardHeight > 0 ? _keyboardHeight : _maxHeight * 0.4;
        final _config = panelConfig.copyWith(maxHeight: _maxHeight, minHeight: _minHeight);
        return widget.builder(_config);
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

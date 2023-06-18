import 'package:flutter/material.dart';

class KeyboardVisibility extends StatefulWidget {
  const KeyboardVisibility({
    Key? key,
    required this.child,
    this.onVisibleChanged,
  }) : super(key: key);

  final Function(bool visible)? onVisibleChanged;
  final Widget child;

  @override
  State<KeyboardVisibility> createState() => _KeyboardVisibilityState();
}

class _KeyboardVisibilityState extends State<KeyboardVisibility> with WidgetsBindingObserver {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final visible = bottomInset > 0.0;

    if (visible != _visible) {
      _visible = visible;
      widget.onVisibleChanged?.call(_visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

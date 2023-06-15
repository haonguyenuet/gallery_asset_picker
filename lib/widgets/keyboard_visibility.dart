import 'package:flutter/material.dart';

typedef KeyboardVisibilityBuilder = Widget Function(BuildContext context, bool isKeyboardVisible, Widget? child);
typedef KeyboardVisibilityListener = void Function(bool visible);

class KeyboardVisibility extends StatefulWidget {
  const KeyboardVisibility({
    Key? key,
    this.child,
    this.listener,
    this.builder,
  }) : super(key: key);

  final KeyboardVisibilityBuilder? builder;
  final KeyboardVisibilityListener? listener;
  final Widget? child;

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
    final viewInsets = View.of(context).viewInsets;
    final bottomInset = viewInsets.bottom;

    final visible = bottomInset > 0.0;

    if (visible != _visible) {
      _visible = visible;
      widget.listener?.call(visible);
      if (widget.builder != null) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, _visible, widget.child) ?? widget.child ?? const SizedBox();
  }
}

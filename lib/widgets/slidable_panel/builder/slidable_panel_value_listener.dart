import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/slidable_panel.dart';

class SlidablePanelValueListener extends StatefulWidget {
  const SlidablePanelValueListener({
    Key? key,
    required this.controller,
    required this.listener,
    required this.child,
  }) : super(key: key);

  final SlidablePanelController controller;
  final Function(BuildContext context, SlidablePanelValue value) listener;
  final Widget child;

  @override
  State<SlidablePanelValueListener> createState() => _SlidablePanelValueListenerState();
}

class _SlidablePanelValueListenerState extends State<SlidablePanelValueListener> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    return widget.listener(context, widget.controller.value);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

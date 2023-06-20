import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/widgets/slide_sheet/slide_sheet.dart';

class SlideSheetValueListener extends StatefulWidget {
  const SlideSheetValueListener({
    Key? key,
    required this.controller,
    required this.listener,
    required this.child,
  }) : super(key: key);

  final SlideSheetController controller;
  final Function(BuildContext context, SlideSheetValue value) listener;
  final Widget child;

  @override
  State<SlideSheetValueListener> createState() => _SlideSheetValueListenerState();
}

class _SlideSheetValueListenerState extends State<SlideSheetValueListener> {
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

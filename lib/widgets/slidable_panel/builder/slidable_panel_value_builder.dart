import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/slidable_panel.dart';

class SlidablePanelValueBuilder extends StatelessWidget {
  const SlidablePanelValueBuilder({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final SlidablePanelController controller;
  final Widget Function(BuildContext context, SlidablePanelValue value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SlidablePanelValue>(
      valueListenable: controller,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

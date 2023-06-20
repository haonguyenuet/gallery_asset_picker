import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/widgets/slide_sheet/slide_sheet.dart';

class SlideSheetValueBuilder extends StatelessWidget {
  const SlideSheetValueBuilder({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final SlideSheetController controller;
  final Widget Function(BuildContext context, SlideSheetValue value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SlideSheetValue>(
      valueListenable: controller,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

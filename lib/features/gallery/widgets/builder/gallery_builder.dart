import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:gallery_asset_picker/features/gallery/values/gallery_value.dart';

typedef GalleryWidgetBuilder = Widget Function(BuildContext context, GalleryValue value);

class GalleryBuilder extends StatelessWidget {
  const GalleryBuilder({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final GalleryController controller;
  final GalleryWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GalleryValue>(
      valueListenable: controller,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

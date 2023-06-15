import 'package:flutter/material.dart';

import '../../controllers/gallery_controller.dart';
import '../../entities/gallery_entity.dart';

typedef GalleryWidgetBuilder = Widget Function(BuildContext context, GalleryEntity value);

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
    return ValueListenableBuilder<GalleryEntity>(
      valueListenable: controller,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

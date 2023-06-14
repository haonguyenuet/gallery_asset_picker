// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';

import '../controllers/gallery_controller.dart';
import '../entities/gallery_entity.dart';

class GalleryBuilder extends StatelessWidget {
  const GalleryBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  final GalleryController controller;
  final Widget Function(GalleryEntity value) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GalleryEntity>(
      valueListenable: controller,
      builder: (context, value, child) => builder(value),
      child: child,
    );
  }
}

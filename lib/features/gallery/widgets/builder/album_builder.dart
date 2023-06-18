import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';

typedef AlbumWidgetBuilder = Widget Function(BuildContext context, AlbumValue album);

class AlbumBuilder extends StatelessWidget {
  const AlbumBuilder({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final AlbumController controller;
  final AlbumWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumValue>(
      valueListenable: controller,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

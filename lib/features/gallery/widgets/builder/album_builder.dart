import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';

typedef AlbumWidgetBuilder = Widget Function(BuildContext context, Album album);
typedef CurrentAlbumWidgetBuilder = Widget Function(BuildContext context, AlbumController albumController);

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
    return ValueListenableBuilder<Album>(
      valueListenable: controller,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

class CurrentAlbumBuilder extends StatelessWidget {
  const CurrentAlbumBuilder({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final ValueNotifier<AlbumController> controller;
  final CurrentAlbumWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumController>(
      valueListenable: controller,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

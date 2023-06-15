import 'package:flutter/material.dart';

import '../../controllers/album_controller.dart';
import '../../controllers/albums_controller.dart';
import '../../entities/album_entity.dart';

typedef AlbumWidgetBuilder = Widget Function(BuildContext context, AlbumEntity album);
typedef CurrentAlbumWidgetBuilder = Widget Function(BuildContext context, AlbumController albumController);

class AlbumBuilder extends StatelessWidget {
  const AlbumBuilder({
    Key? key,
    required this.albumController,
    this.builder,
  }) : super(key: key);

  final AlbumController albumController;
  final AlbumWidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumEntity>(
      valueListenable: albumController,
      builder: (context, value, child) => builder?.call(context, value) ?? const SizedBox(),
    );
  }
}

class CurrentAlbumBuilder extends StatelessWidget {
  const CurrentAlbumBuilder({
    Key? key,
    required this.albumsController,
    this.builder,
  }) : super(key: key);

  final AlbumsController albumsController;
  final CurrentAlbumWidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumController>(
      valueListenable: albumsController.currentAlbumController,
      builder: (context, value, child) => builder?.call(context, value) ?? const SizedBox(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';

typedef AlbumWidgetBuilder = Widget Function(BuildContext context, Album album);
typedef CurrentAlbumWidgetBuilder = Widget Function(BuildContext context, AlbumNotifier albumNotifier);

class AlbumBuilder extends StatelessWidget {
  const AlbumBuilder({
    Key? key,
    required this.notifier,
    required this.builder,
  }) : super(key: key);

  final AlbumNotifier notifier;
  final AlbumWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Album>(
      valueListenable: notifier,
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

  final AlbumListNotifier controller;
  final CurrentAlbumWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumNotifier>(
      valueListenable: controller.currentAlbumNotifier,
      builder: (context, value, child) => builder.call(context, value),
    );
  }
}

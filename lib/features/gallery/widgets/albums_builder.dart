import 'package:flutter/material.dart';

import '../../../widgets/gallery_permission_view.dart';
import '../controllers/album_controller.dart';
import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../entities/album_entity.dart';
import '../entities/albums_entity.dart';
import '../enums/fetching_state.dart';

typedef AlbumsWidgetBuilder = Widget Function(BuildContext context, AlbumsEntity albums);
typedef AlbumWidgetBuilder = Widget Function(BuildContext context, AlbumEntity album);
typedef CurrentAlbumWidgetBuilder = Widget Function(BuildContext context, AlbumController albumController);

class AlbumsBuilder extends StatelessWidget {
  const AlbumsBuilder({
    Key? key,
    required this.controller,
    required this.albumsController,
    this.builder,
    this.hidePermissionView = false,
  }) : super(key: key);

  final GalleryController controller;
  final AlbumsController albumsController;
  final AlbumsWidgetBuilder? builder;
  final bool hidePermissionView;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AlbumsEntity>(
      valueListenable: albumsController,
      builder: (context, value, child) {
        if (value.state == AssetFetchingState.unauthorised && value.albumControllers.isEmpty && !hidePermissionView) {
          return GalleryPermissionView(
            onRefresh: () {
              albumsController.fetchAlbums(controller.setting.requestType);
            },
          );
        }

        // No data
        if (value.state == AssetFetchingState.completed && value.albumControllers.isEmpty) {
          return const Center(
            child: Text(
              'No albums available',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (value.state == AssetFetchingState.error) {
          return const Center(
            child: Text(
              'Something went wrong. Please try again!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return builder?.call(context, value) ?? const SizedBox();
      },
    );
  }
}

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

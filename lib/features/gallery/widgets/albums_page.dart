import 'package:flutter/material.dart';
import 'package:modern_media_picker/utils/const.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../controllers/album_controller.dart';
import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../entities/album_entity.dart';
import 'builder/albums_builder.dart';
import 'gallery_asset_thumbnail.dart';

const _imageSize = 48;

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({
    Key? key,
    required this.controller,
    required this.onAlbumChange,
    required this.albumsController,
  }) : super(key: key);

  final GalleryController controller;
  final AlbumsController albumsController;
  final ValueSetter<AlbumController> onAlbumChange;

  @override
  Widget build(BuildContext context) {
    return AlbumsBuilder(
      controller: controller,
      albumsController: albumsController,
      hidePermissionView: true,
      builder: (context, albumsController) {
        if (albumsController.albumControllers.isEmpty) {
          return Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: const Text(
              StringConst.NO_ALBUM_AVAILABLE,
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ColoredBox(
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: albumsController.albumControllers.length,
            itemBuilder: (context, index) {
              final albumController = albumsController.albumControllers[index];
              return AlbumTile(
                controller: controller,
                albumController: albumController,
                onPressed: onAlbumChange,
              );
            },
          ),
        );
      },
    );
  }
}

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    Key? key,
    required this.controller,
    required this.albumController,
    this.onPressed,
  }) : super(key: key);

  final GalleryController controller;
  final AlbumController albumController;
  final ValueChanged<AlbumController>? onPressed;

  AlbumEntity get album => albumController.value;

  Future<AssetEntity?> get firstAsset async {
    final assets = (await album.assetPathEntity?.getAssetListPaged(page: 0, size: 1)) ?? [];
    if (assets.isEmpty) return null;
    return assets.first;
  }

  @override
  Widget build(BuildContext context) {
    final isAll = album.assetPathEntity?.isAll ?? true;

    return GestureDetector(
      onTap: () => onPressed?.call(albumController),
      child: Container(
        padding: const EdgeInsets.only(left: 16, bottom: 20, right: 16),
        color: Colors.black,
        child: Row(
          children: [
            // Image
            Container(
              height: _imageSize.toDouble(),
              width: _imageSize.toDouble(),
              color: Colors.grey.shade800,
              child: FutureBuilder<AssetEntity?>(
                future: firstAsset,
                builder: (context, snapshot) {
                  final asset = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done || asset == null) {
                    return const SizedBox();
                  }
                  return ColoredBox(
                    color: Colors.grey.shade800,
                    child: AssetThumbnail(asset: asset.toPlus),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAll ? StringConst.ALL_PHOTOS : album.assetPathEntity?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<int>(
                    future: album.assetPathEntity?.assetCountAsync,
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) return const SizedBox();
                      return Text(
                        snapshot.data.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

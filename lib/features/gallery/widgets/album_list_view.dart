import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/const.dart';

const _imageSize = 48;

class AlbumListView extends StatelessWidget {
  const AlbumListView({Key? key, required this.onAlbumChange}) : super(key: key);

  final ValueSetter<AlbumController> onAlbumChange;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return ColoredBox(
      color: Colors.black,
      child: AlbumListBuilder(
        controller: galleryController.albumListController,
        hidePermissionView: true,
        builder: (context, albumList) {
          if (albumList.albumControllers.isEmpty) {
            return const Center(
              child: Text(
                StringConst.NO_ALBUM_AVAILABLE,
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: albumList.albumControllers.length,
            itemBuilder: (context, index) {
              final albumController = albumList.albumControllers[index];
              return _AlbumTile(
                albumController: albumController,
                onPressed: onAlbumChange,
              );
            },
          );
        },
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({Key? key, required this.albumController, this.onPressed}) : super(key: key);

  final AlbumController albumController;
  final ValueChanged<AlbumController>? onPressed;

  AlbumValue get album => albumController.value;

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
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 20, right: 16),
        child: Row(
          children: [
            Container(
              height: _imageSize.toDouble(),
              width: _imageSize.toDouble(),
              color: Colors.grey.shade700,
              child: FutureBuilder<AssetEntity?>(
                future: firstAsset,
                builder: (context, snapshot) {
                  final asset = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done || asset == null) {
                    return const SizedBox();
                  }
                  return AssetThumbnail(asset: asset.toGalleryAsset);
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
                      final assetCount = snapshot.data;
                      if (snapshot.connectionState != ConnectionState.done || assetCount == null) {
                        return const SizedBox();
                      }
                      return Text(
                        snapshot.data.toString(),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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

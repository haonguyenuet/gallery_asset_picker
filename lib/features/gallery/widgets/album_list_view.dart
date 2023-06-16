import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_list_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_asset_thumbnail.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:photo_manager/photo_manager.dart';

const _imageSize = 48;

class AlbumListPage extends StatelessWidget {
  const AlbumListPage({
    Key? key,
    required this.albumListNotifier,
    required this.onAlbumChange,
  }) : super(key: key);

  final AlbumListNotifier albumListNotifier;
  final ValueSetter<AlbumNotifier> onAlbumChange;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: AlbumListBuilder(
        notifier: albumListNotifier,
        hidePermissionView: true,
        builder: (context, albumListNotifier) {
          if (albumListNotifier.albumNotifiers.isEmpty) {
            return const Center(
              child: Text(
                StringConst.NO_ALBUM_AVAILABLE,
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: albumListNotifier.albumNotifiers.length,
            itemBuilder: (context, index) {
              final albumNotifier = albumListNotifier.albumNotifiers[index];
              return _AlbumTile(
                albumNotifier: albumNotifier,
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
  const _AlbumTile({Key? key, required this.albumNotifier, this.onPressed}) : super(key: key);

  final AlbumNotifier albumNotifier;
  final ValueChanged<AlbumNotifier>? onPressed;

  Album get album => albumNotifier.value;

  Future<AssetEntity?> get firstAsset async {
    final assets = (await album.assetPathEntity?.getAssetListPaged(page: 0, size: 1)) ?? [];
    if (assets.isEmpty) return null;
    return assets.first;
  }

  @override
  Widget build(BuildContext context) {
    final isAll = album.assetPathEntity?.isAll ?? true;

    return GestureDetector(
      onTap: () => onPressed?.call(albumNotifier),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 20, right: 16),
        child: Row(
          children: [
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

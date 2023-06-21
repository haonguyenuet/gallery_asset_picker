import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';

const _imageSize = 48;

class AlbumListView extends StatelessWidget {
  const AlbumListView({Key? key, required this.onAlbumChange}) : super(key: key);

  final ValueSetter<AlbumController> onAlbumChange;

  @override
  Widget build(BuildContext context) {
    final colorScheme = GalleryManager.config.colorScheme;
    final textTheme = GalleryManager.config.textTheme;

    return ColoredBox(
      color: colorScheme.background,
      child: AlbumListBuilder(
        controller: GalleryManager.controller.albumListController,
        hidePermissionView: true,
        builder: (context, albumList) {
          if (albumList.albumControllers.isEmpty) {
            return Center(
              child: Text(
                StringConst.NO_ALBUM_AVAILABLE,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
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
                isCurrent: albumController.value == albumList.currentAlbumController?.value,
              );
            },
          );
        },
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    Key? key,
    required this.albumController,
    required this.isCurrent,
    this.onPressed,
  }) : super(key: key);

  final AlbumController albumController;
  final ValueChanged<AlbumController>? onPressed;
  final bool isCurrent;

  AlbumValue get album => albumController.value;

  @override
  Widget build(BuildContext context) {
    final isAll = album.path?.isAll ?? true;
    final colorScheme = GalleryManager.config.colorScheme;
    final textTheme = GalleryManager.config.textTheme;

    final assetCount = album.assetCount;
    final firstAsset = album.firstAsset;
    if (assetCount == 0) return const SizedBox();
    return GestureDetector(
      onTap: () => onPressed?.call(albumController),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 20, right: 16),
        child: Row(
          children: [
            Container(
              height: _imageSize.toDouble(),
              width: _imageSize.toDouble(),
              color: colorScheme.brightness == Brightness.light ? Colors.grey.shade300 : Colors.grey.shade700,
              child: firstAsset != null ? AssetThumbnail(asset: firstAsset.toGalleryAsset) : const SizedBox(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAll ? StringConst.ALL_PHOTOS : album.path?.name ?? '',
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onBackground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assetCount.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.brightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 16),
              Icon(CupertinoIcons.checkmark_alt, color: colorScheme.onBackground),
            ]
          ],
        ),
      ),
    );
  }
}

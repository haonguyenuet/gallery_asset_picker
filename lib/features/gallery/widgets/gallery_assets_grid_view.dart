import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

class GalleryAssetsGridView extends StatelessWidget {
  const GalleryAssetsGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    final colorScheme = galleryController.setting.colorScheme;
    final textTheme = galleryController.setting.textTheme;
    return ColoredBox(
      color: colorScheme.background,
      child: AlbumListBuilder(
        controller: galleryController.albumListController,
        builder: (context, albumList) {
          final currentAlbumController = albumList.currentAlbumController ?? AlbumController();
          return AlbumBuilder(
            controller: currentAlbumController,
            builder: (context, currentAlbum) {
              if (currentAlbum.fetchStatus == FetchStatus.unauthorised && currentAlbum.assets.isEmpty) {
                return GalleryPermissionView(
                  onRefresh: () {
                    if (currentAlbum.assetPathEntity == null) {
                      galleryController.albumListController.fetchAlbums(galleryController.setting.requestType);
                    } else {
                      albumList.currentAlbumController!.fetchAssets();
                    }
                  },
                );
              }

              if (currentAlbum.fetchStatus == FetchStatus.completed && currentAlbum.assets.isEmpty) {
                return Center(
                  child: Text(
                    StringConst.NO_MEDIA_AVAILABLE,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
                  ),
                );
              }

              if (currentAlbum.fetchStatus == FetchStatus.error) {
                return Center(
                  child: Text(
                    StringConst.SOMETHING_WRONG,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
                  ),
                );
              }

              final assets = currentAlbum.assets;
              final enableCamera = galleryController.setting.enableCamera;

              final itemCount = galleryController.albumListController.value.fetchStatus == FetchStatus.fetching
                  ? 20
                  : enableCamera
                      ? assets.length + 1
                      : assets.length;

              return LazyLoadScrollView(
                onEndOfPage: currentAlbumController.fetchAssets,
                scrollOffset: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: galleryController.slidablePanelController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: galleryController.setting.crossAxisCount,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: itemCount,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (enableCamera && index == 0) {
                      return _CameraTile(currentAlbumController);
                    }

                    final i = enableCamera ? index - 1 : index;
                    final asset = galleryController.albumListController.value.fetchStatus == FetchStatus.fetching
                        ? null
                        : assets[i];
                    if (asset == null) {
                      return Container(
                          color:
                              colorScheme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade800);
                    }

                    return _AssetTile(key: ValueKey(asset.id), asset: asset);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CameraTile extends StatelessWidget {
  const _CameraTile(this.albumController);

  final AlbumController albumController;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return Container(
      color: Colors.black,
      child: InkWell(
        child: const Icon(CupertinoIcons.camera, color: Colors.white, size: 24),
        onTap: () async {
          final asset = await galleryController.openCamera(context);
          if (asset != null) albumController.insert(asset);
        },
      ),
    );
  }
}

///
class _AssetTile extends StatelessWidget {
  const _AssetTile({Key? key, required this.asset}) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    Uint8List? bytes;
    return InkWell(
      onTap: () {
        final pickedAsset = asset.toGalleryAsset.copyWith(pickedThumbData: bytes);
        galleryController.select(pickedAsset);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetThumbnail(asset: asset.toGalleryAsset, onBytesGenerated: (_bytes) => bytes = _bytes),
          _SelectionCount(asset: asset),
        ],
      ),
    );
  }
}

class _SelectionCount extends StatelessWidget {
  const _SelectionCount({Key? key, required this.asset}) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    final colorScheme = context.galleryController.setting.colorScheme;
    final textTheme = context.galleryController.setting.textTheme;

    return GalleryBuilder(
      controller: galleryController,
      builder: (context, gallery) {
        final singleSelection = galleryController.singleSelection;
        final isSelected = gallery.selectedAssets.contains(asset);
        final index = gallery.selectedAssets.indexOf(asset.toGalleryAsset);
        final ratio = 3 / galleryController.setting.crossAxisCount;

        Widget counter = const SizedBox();
        if (isSelected) {
          counter = CircleAvatar(
            backgroundColor: colorScheme.primary,
            radius: 14 * ratio,
            child: singleSelection
                ? Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 24 * ratio)
                : Text(
                    '${index + 1}',
                    style: textTheme.titleSmall?.copyWith(color: Colors.white, fontSize: 14 * ratio),
                  ),
          );
        }
        if (!singleSelection) {
          counter = Container(
            height: 22 * ratio,
            width: 22 * ratio,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2, strokeAlign: 0),
            ),
            child: isSelected ? counter : const SizedBox(),
          );
        }

        return Container(
          color: isSelected ? Colors.white38 : Colors.transparent,
          padding: const EdgeInsets.all(6),
          child: Align(alignment: singleSelection ? Alignment.center : Alignment.topRight, child: counter),
        );
      },
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_builder.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:gallery_asset_picker/widgets/gallery_permission_view.dart';

class GalleryAssetsGridView extends StatelessWidget {
  const GalleryAssetsGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return ColoredBox(
      color: Colors.black,
      child: CurrentAlbumBuilder(
        controller: galleryController.albumListController.currentAlbumController,
        builder: (context, albumController) {
          return AlbumBuilder(
            controller: albumController,
            builder: (context, album) {
              if (album.fetchState == FetchState.unauthorised && album.assets.isEmpty) {
                return GalleryPermissionView(
                  onRefresh: () {
                    if (album.assetPathEntity == null) {
                      galleryController.albumListController.fetchAlbums(galleryController.setting.requestType);
                    } else {
                      albumController.fetchAssets();
                    }
                  },
                );
              }

              if (album.fetchState == FetchState.completed && album.assets.isEmpty) {
                return const Center(
                  child: Text(StringConst.NO_MEDIA_AVAILABLE, style: TextStyle(color: Colors.white)),
                );
              }

              if (album.fetchState == FetchState.error) {
                return const Center(
                  child: Text(StringConst.SOMETHING_WRONG, style: TextStyle(color: Colors.white)),
                );
              }

              final assets = album.assets;
              final enableCamera = galleryController.setting.enableCamera;

              final itemCount = galleryController.albumListController.value.fetchState == FetchState.fetching
                  ? 20
                  : enableCamera
                      ? assets.length + 1
                      : assets.length;

              return LazyLoadScrollView(
                onEndOfPage: albumController.fetchAssets,
                scrollOffset: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: galleryController.slidablePanelController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: galleryController.setting.crossAxisCount,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: itemCount,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (enableCamera && index == 0) {
                      return _CameraTile(albumController);
                    }

                    final i = enableCamera ? index - 1 : index;
                    final entity = galleryController.albumListController.value.fetchState == FetchState.fetching
                        ? null
                        : assets[i];

                    if (entity == null) return const SizedBox();
                    return _AssetTile(asset: entity);
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
    return InkWell(
      onTap: () async {
        final asset = await galleryController.openCamera(context);
        if (asset != null) albumController.insert(asset);
      },
      child: Icon(
        CupertinoIcons.camera,
        color: Colors.grey.shade200,
        size: 24,
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
        final entity = asset.toGalleryAsset.copyWith(pickedThumbData: bytes);
        galleryController.select(entity);
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
    return GalleryBuilder(
      controller: galleryController,
      builder: (context, gallery) {
        final singleSelection = galleryController.singleSelection;
        final isSelected = gallery.selectedAssets.contains(asset);
        final index = gallery.selectedAssets.indexOf(asset.toGalleryAsset);
        final counterRaito = 3 / galleryController.setting.crossAxisCount;

        Widget counter = const SizedBox();
        if (isSelected) {
          counter = CircleAvatar(
            backgroundColor: galleryController.setting.theme?.primaryColor ?? Theme.of(context).primaryColor,
            radius: 14 * counterRaito,
            child: singleSelection
                ? Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 24 * counterRaito)
                : Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 16 * counterRaito)),
          );
        }
        if (!singleSelection) {
          counter = Container(
            height: 30 * counterRaito,
            width: 30 * counterRaito,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: isSelected ? counter : const SizedBox(),
          );
        }

        return Container(
          color: isSelected ? Colors.white38 : Colors.transparent,
          padding: const EdgeInsets.all(6),
          child: Align(alignment: Alignment.topRight, child: counter),
        );
      },
    );
  }
}

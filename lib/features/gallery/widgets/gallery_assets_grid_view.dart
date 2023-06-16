import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/gallery_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_asset_thumbnail.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:gallery_asset_picker/widgets/gallery_permission_view.dart';
import 'package:gallery_asset_picker/widgets/lazy_load_scroll_view.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryAssetsGridView extends StatelessWidget {
  const GalleryAssetsGridView({
    Key? key,
    required this.albumListNotifier,
    required this.onClose,
  }) : super(key: key);

  final AlbumListNotifier albumListNotifier;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return ColoredBox(
      color: Colors.black,
      child: CurrentAlbumBuilder(
        controller: albumListNotifier,
        builder: (context, currentAlbumNotifier) {
          return AlbumBuilder(
            notifier: currentAlbumNotifier,
            builder: (context, album) {
              if (album.fetchState == FetchState.unauthorised && album.assets.isEmpty) {
                return GalleryPermissionView(
                  onRefresh: () {
                    if (album.assetPathEntity == null) {
                      albumListNotifier.fetchAlbums(galleryController.setting.requestType);
                    } else {
                      currentAlbumNotifier.fetchAssets();
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

              final itemCount = albumListNotifier.value.fetchState == FetchState.fetching
                  ? 20
                  : enableCamera
                      ? assets.length + 1
                      : assets.length;

              return LazyLoadScrollView(
                onEndOfPage: currentAlbumNotifier.fetchAssets,
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
                      return const _CameraTile();
                    }

                    final i = enableCamera ? index - 1 : index;
                    final entity = albumListNotifier.value.fetchState == FetchState.fetching ? null : assets[i];

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
  const _CameraTile();

  @override
  Widget build(BuildContext context) {
    // final galleryController = context.galleryController;
    return InkWell(
      onTap: () {
        // TODO(Haonguyen): OPEN CAMERA
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
            backgroundColor: galleryController.setting.theme?.primaryColor,
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

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modern_media_picker/utils/const.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../../../widgets/gallery_permission_view.dart';
import '../../../widgets/lazy_load_scroll_view.dart';
import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../enums/fetching_state.dart';
import 'builder/album_builder.dart';
import 'builder/gallery_builder.dart';
import 'gallery_asset_thumbnail.dart';

class GalleryAssetsGridView extends StatelessWidget {
  const GalleryAssetsGridView({
    Key? key,
    required this.controller,
    required this.albumsController,
    required this.onClose,
  }) : super(key: key);

  final GalleryController controller;
  final AlbumsController albumsController;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: controller.slidablePanelSetting.foregroundColor,
      child: CurrentAlbumBuilder(
        albumsController: albumsController,
        builder: (context, albumController) {
          return AlbumBuilder(
            albumController: albumController,
            builder: (context, album) {
              if (album.state == AssetFetchingState.unauthorised && album.assets.isEmpty) {
                return GalleryPermissionView(
                  onRefresh: () {
                    if (album.assetPathEntity == null) {
                      albumsController.fetchAlbums(controller.setting.requestType);
                    } else {
                      albumController.fetchAssets();
                    }
                  },
                );
              }

              if (album.state == AssetFetchingState.completed && album.assets.isEmpty) {
                return const Center(
                  child: Text(StringConst.NO_MEDIA_AVAILABLE, style: TextStyle(color: Colors.white)),
                );
              }

              if (album.state == AssetFetchingState.error) {
                return const Center(
                  child: Text(StringConst.SOMETHING_WRONG, style: TextStyle(color: Colors.white)),
                );
              }

              final assets = album.assets;
              final enableCamera = controller.setting.enableCamera;

              final itemCount = albumsController.value.state == AssetFetchingState.fetching
                  ? 20
                  : enableCamera
                      ? assets.length + 1
                      : assets.length;

              return LazyLoadScrollView(
                onEndOfPage: albumController.fetchAssets,
                scrollOffset: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: controller.slidablePanelController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: controller.setting.crossAxisCount,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                  ),
                  itemCount: itemCount,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (enableCamera && index == 0) {
                      return const CameraTile();
                    }

                    final assetIndex = enableCamera ? index - 1 : index;
                    final entity =
                        albumsController.value.state == AssetFetchingState.fetching ? null : assets[assetIndex];

                    if (entity == null) return const SizedBox();
                    return AssetTile(controller: controller, asset: entity);
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

class CameraTile extends StatelessWidget {
  const CameraTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // controller.openCamera(context).then((value) {
        //   if (value != null) {
        //     albumController.insert(value);
        //   }
        // });
      },
      child: Icon(
        CupertinoIcons.camera,
        color: Colors.grey.shade300,
        size: 26,
      ),
    );
  }
}

///
class AssetTile extends StatelessWidget {
  const AssetTile({Key? key, required this.asset, required this.controller}) : super(key: key);

  final GalleryController controller;
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    return ColoredBox(
      color: const Color.fromARGB(255, 0, 0, 0),
      child: InkWell(
        onTap: () {
          final entity = asset.toPlus.copyWith(pickedThumbData: bytes);
          controller.select(entity);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AssetThumbnail(asset: asset.toPlus, onBytesGenerated: (_bytes) => bytes = _bytes),
            SelectionCount(controller: controller, asset: asset),
          ],
        ),
      ),
    );
  }
}

class SelectionCount extends StatelessWidget {
  const SelectionCount({Key? key, required this.controller, required this.asset}) : super(key: key);

  final GalleryController controller;
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: controller,
      builder: (context, gallery) {
        final singleSelection = controller.singleSelection;

        final isSelected = gallery.selectedAssets.contains(asset);
        final index = gallery.selectedAssets.indexOf(asset.toPlus);

        Widget counter = const SizedBox();
        if (isSelected) {
          counter = CircleAvatar(
            backgroundColor: controller.setting.theme?.primaryColor,
            radius: 14,
            child: singleSelection
                ? const Icon(Icons.check, color: Colors.white)
                : Text('${index + 1}', style: const TextStyle(color: Colors.white)),
          );
        }
        if (!singleSelection) {
          counter = Container(
            height: 30,
            width: 30,
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

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../../../widgets/gallery_permission_view.dart';
import '../../../widgets/lazy_load_scroll_view.dart';
import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../entities/gallery_settings.dart';
import '../enums/fetching_state.dart';
import 'albums_builder.dart';
import 'entity_thumbnail.dart';
import 'gallery_builder.dart';

///
class GalleryGridView extends StatelessWidget {
  const GalleryGridView({
    Key? key,
    required this.controller,
    required this.albumsController,
    required this.onClosePressed,
  }) : super(key: key);

  final GalleryController controller;
  final AlbumsController albumsController;
  final VoidCallback? onClosePressed;

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
              // Error
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

              // No data
              if (album.state == AssetFetchingState.completed && album.assets.isEmpty) {
                return const Center(
                  child: Text(
                    'No media available',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              if (album.state == AssetFetchingState.error) {
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
                          color: Colors.lightBlue.shade300,
                          size: 26,
                        ),
                      );
                    }

                    final ind = enableCamera ? index - 1 : index;
                    final entity = albumsController.value.state == AssetFetchingState.fetching ? null : assets[ind];

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

///
class AssetTile extends StatelessWidget {
  const AssetTile({
    Key? key,
    required this.asset,
    required this.controller,
  }) : super(key: key);

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
            AssetThumbnail(
              asset: asset.toPlus,
              onBytesGenerated: (_bytes) => bytes = _bytes,
            ),
            SelectionCount(controller: controller, entity: asset),
          ],
        ),
      ),
    );
  }
}

class SelectionCount extends StatelessWidget {
  const SelectionCount({
    Key? key,
    required this.controller,
    required this.entity,
  }) : super(key: key);

  final GalleryController controller;
  final AssetEntity entity;

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: controller,
      builder: (value) {
        final actionBased = controller.setting.selectionMode == SelectionMode.actionBased;
        final singleSelection = actionBased ? !value.allowMultiple : controller.singleSelection;

        final isSelected = value.selectedAssets.contains(entity);
        final index = value.selectedAssets.indexOf(entity.toPlus);

        Widget counter = const SizedBox();

        if (isSelected) {
          counter = CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 14,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.button?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          );
        }

        if (actionBased && !singleSelection) {
          counter = Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: isSelected ? counter : const SizedBox(),
          );
        }

        return Container(
          color: isSelected ? Colors.white38 : Colors.transparent,
          padding: const EdgeInsets.all(6),
          child: Align(
            alignment: actionBased ? Alignment.topRight : Alignment.center,
            child: counter,
          ),
        );
      },
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/camera/camera.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryAssetsGridView extends StatelessWidget {
  const GalleryAssetsGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: GAPManager.colorScheme.background,
      child: AlbumListBuilder(
        controller: GAPManager.albumListController,
        builder: (context, albumList) {
          final currentAlbumController = albumList.currentAlbumController ?? AlbumController();
          return AlbumBuilder(
            controller: currentAlbumController,
            builder: (context, currentAlbum) {
              if (currentAlbum.fetchStatus == FetchStatus.unauthorised && currentAlbum.assets.isEmpty) {
                return GalleryPermissionView(
                  onRefresh: () {
                    if (currentAlbum.path == null) {
                      GAPManager.controller.fetchAlbums();
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
                    style: GAPManager.textTheme.bodyMedium?.copyWith(color: GAPManager.colorScheme.onBackground),
                  ),
                );
              }

              if (currentAlbum.fetchStatus == FetchStatus.error) {
                return Center(
                  child: Text(
                    StringConst.SOMETHING_WRONG,
                    style: GAPManager.textTheme.bodyMedium?.copyWith(color: GAPManager.colorScheme.onBackground),
                  ),
                );
              }

              final assets = currentAlbum.assets;
              final enableCamera = GAPManager.config.enableCamera;

              final itemCount = GAPManager.albumListController.value.fetchStatus == FetchStatus.fetching
                  ? 20
                  : enableCamera
                      ? assets.length + 1
                      : assets.length;

              return LazyLoadScrollView(
                onEndOfPage: currentAlbumController.fetchAssets,
                scrollOffset: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: GAPManager.slideSheetController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GAPManager.config.crossAxisCount,
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
                    final asset =
                        GAPManager.albumListController.value.fetchStatus == FetchStatus.fetching ? null : assets[i];
                    if (asset == null) {
                      return Container(
                          color: GAPManager.colorScheme.brightness == Brightness.light
                              ? Colors.grey.shade200
                              : Colors.grey.shade800);
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
    return Container(
      color: Colors.black,
      child: InkWell(
        child: const Icon(CupertinoIcons.camera, color: Colors.white, size: 24),
        onTap: () async {
          final asset = await openCamera(context);
          GAPManager.albumListController.changeCurrentAlbumControllerToAll();
          if (asset != null) GAPManager.albumListController.value.currentAlbumController?.insert(asset);
        },
      ),
    );
  }

  Future<GalleryAsset?> openCamera(BuildContext context) async {
    final cameraRoute = SlidingPageRoute<List<GalleryAsset>>(
      child: CameraPage(controller: XCameraController()),
      setting: const SlidingRouteSettings(start: TransitionFrom.bottomToTop, reverse: TransitionFrom.topToBottom),
    );

    final assets = await NavigatorUtils.of(context).push(cameraRoute);
    await SystemUtils.showStatusBar();

    if (assets?.isNotEmpty == true) {
      final asset = assets!.first;
      GAPManager.controller.select(asset);
      return asset;
    }
    return null;
  }
}

///
class _AssetTile extends StatelessWidget {
  const _AssetTile({Key? key, required this.asset}) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    return InkWell(
      onTap: () {
        final pickedAsset = asset.toGalleryAsset.copyWith(pickedThumbData: bytes);
        GAPManager.controller.select(pickedAsset);
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
    return GalleryBuilder(
      controller: GAPManager.controller,
      builder: (context, gallery) {
        final singleSelection = GAPManager.controller.singleSelection;
        final isSelected = gallery.selectedAssets.contains(asset);
        final index = gallery.selectedAssets.indexOf(asset.toGalleryAsset);
        final ratio = 3 / GAPManager.config.crossAxisCount;

        Widget counter = const SizedBox();
        if (isSelected) {
          counter = CircleAvatar(
            backgroundColor: GAPManager.colorScheme.primary,
            radius: 14 * ratio,
            child: singleSelection
                ? Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 24 * ratio)
                : Text(
                    '${index + 1}',
                    style: GAPManager.textTheme.titleSmall?.copyWith(color: Colors.white, fontSize: 14 * ratio),
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

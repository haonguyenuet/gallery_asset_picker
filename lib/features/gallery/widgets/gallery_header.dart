import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/gallery_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key? key,
    required this.onClose,
    required this.onAlbumToggle,
    required this.albumListNotifier,
    required this.galleryController,
    this.headerSubtitle,
  }) : super(key: key);

  final AlbumListNotifier albumListNotifier;
  final GalleryController galleryController;
  final void Function() onClose;
  final void Function(bool visible) onAlbumToggle;
  final String? headerSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minHeight: galleryController.slidablePanelSetting.handleBarHeight,
        maxHeight: galleryController.slidablePanelSetting.headerHeight,
      ),
      color: galleryController.slidablePanelSetting.headerBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HandleBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildCloseButton(context)),
                FittedBox(
                  child: _AlbumInformation(
                    subtitle: headerSubtitle,
                    albumListNotifier: albumListNotifier,
                    onAlbumToggle: onAlbumToggle,
                  ),
                ),
                Expanded(child: _buildToggleMultiSelection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: const EdgeInsets.all(8),
        minSize: 0,
        child: Icon(
          CupertinoIcons.clear,
          size: 20,
          color: Colors.grey.shade700,
        ),
        onPressed: onClose,
      ),
    );
  }

  Widget _buildToggleMultiSelection() {
    if (galleryController.setting.selectionMode == SelectionMode.countBased) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.centerRight,
      child: GalleryBuilder(
        controller: galleryController,
        builder: (context, gallery) {
          return CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            child: Icon(
              CupertinoIcons.square_stack_3d_up,
              size: 20,
              color: gallery.allowMultiple ? galleryController.setting.theme?.primaryColor : Colors.white38,
            ),
            onPressed: () {
              if (galleryController.value.isAlbumVisible) {
                onAlbumToggle(true);
              } else {
                galleryController.toggleMultiSelection();
              }
            },
          );
        },
      ),
    );
  }
}

class _HandleBar extends StatelessWidget {
  const _HandleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    if (galleryController.isFullScreenMode) {
      return SizedBox(height: MediaQuery.of(context).padding.top);
    }
    return SizedBox(
      height: galleryController.slidablePanelSetting.handleBarHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 40,
            height: 5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _AlbumInformation extends StatelessWidget {
  const _AlbumInformation({
    Key? key,
    this.subtitle,
    required this.albumListNotifier,
    required this.onAlbumToggle,
  }) : super(key: key);

  final String? subtitle;
  final AlbumListNotifier albumListNotifier;
  final void Function(bool visible) onAlbumToggle;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return Row(
      children: [
        CurrentAlbumBuilder(
          controller: albumListNotifier,
          builder: (context, albumNotifier) {
            final isAll = albumNotifier.value.assetPathEntity?.isAll ?? true;
            return Text(
              isAll ? galleryController.setting.albumTitle : albumNotifier.value.assetPathEntity?.name ?? 'Unknown',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            );
          },
        ),
        GalleryBuilder(
          controller: galleryController,
          builder: (context, gallery) {
            return AnimatedOpacity(
              opacity: gallery.selectedAssets.isEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ValueListenableBuilder<bool>(
                valueListenable: galleryController.albumVisibility,
                builder: (context, visible, child) {
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(
                      begin: visible ? 0.0 : 1.0,
                      end: visible ? 1.0 : 0.0,
                    ),
                    builder: (context, factor, child) => Transform.rotate(
                      angle: pi * factor,
                      child: CupertinoButton(
                        minSize: 0,
                        padding: const EdgeInsets.all(4),
                        child: Icon(CupertinoIcons.chevron_down, size: 20, color: Colors.grey.shade700),
                        onPressed: () {
                          if (gallery.selectedAssets.isEmpty) {
                            onAlbumToggle(visible);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

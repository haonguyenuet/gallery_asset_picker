import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../entities/gallery_settings.dart';
import 'builder/album_builder.dart';
import 'builder/gallery_builder.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key? key,
    required this.controller,
    required this.onClose,
    required this.onAlbumToggle,
    required this.albumsController,
    this.headerSubtitle,
  }) : super(key: key);

  final String? headerSubtitle;
  final GalleryController controller;
  final AlbumsController albumsController;
  final void Function() onClose;
  final void Function(bool visible) onAlbumToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minHeight: controller.slidablePanelSetting.handleBarHeight,
        maxHeight: controller.slidablePanelSetting.headerHeight,
      ),
      color: controller.slidablePanelSetting.headerBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HandlerBar(controller: controller),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildCloseButton(context)),
                FittedBox(
                  child: AlbumInformation(
                    subtitle: headerSubtitle,
                    controller: controller,
                    albumsController: albumsController,
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
          size: 28,
          color: Colors.grey.shade700,
        ),
        onPressed: onClose,
      ),
    );
  }

  Widget _buildToggleMultiSelection() {
    if (controller.setting.selectionMode == SelectionMode.countBased) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.centerRight,
      child: GalleryBuilder(
        controller: controller,
        builder: (context, gallery) {
          return CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            onPressed: () {
              if (controller.value.isAlbumVisible) {
                onAlbumToggle(true);
              } else {
                controller.toggleMultiSelection();
              }
            },
            child: Icon(
              CupertinoIcons.square_stack_3d_up,
              size: 28,
              color: gallery.allowMultiple ? controller.setting.theme?.primaryColor : Colors.white38,
            ),
          );
        },
      ),
    );
  }
}

class HandlerBar extends StatelessWidget {
  const HandlerBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isFullScreenMode) {
      return SizedBox(height: MediaQuery.of(context).padding.top);
    }

    return SizedBox(
      height: controller.slidablePanelSetting.handleBarHeight,
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

class AlbumInformation extends StatelessWidget {
  const AlbumInformation({
    Key? key,
    this.subtitle,
    required this.controller,
    required this.albumsController,
    required this.onAlbumToggle,
  }) : super(key: key);

  final String? subtitle;
  final GalleryController controller;
  final AlbumsController albumsController;
  final void Function(bool visible) onAlbumToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CurrentAlbumBuilder(
          albumsController: albumsController,
          builder: (context, albumController) {
            final isAll = albumController.value.assetPathEntity?.isAll ?? true;
            return Text(
              isAll ? controller.setting.albumTitle : albumController.value.assetPathEntity?.name ?? 'Unknown',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            );
          },
        ),
        GalleryBuilder(
          controller: controller,
          builder: (context, gallery) {
            return AnimatedOpacity(
              opacity: gallery.selectedAssets.isEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.albumVisibility,
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
                        onPressed: () {
                          if (controller.value.selectedAssets.isEmpty) {
                            onAlbumToggle(visible);
                          }
                        },
                        child: Icon(CupertinoIcons.chevron_down, size: 20, color: Colors.grey.shade700),
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

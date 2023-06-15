import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/gallery_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';

class GalleryHeader extends StatefulWidget {
  const GalleryHeader({
    Key? key,
    required this.onClose,
    required this.onAlbumToggle,
    required this.albumListNotifier,
    this.headerSubtitle,
  }) : super(key: key);

  final String? headerSubtitle;
  final AlbumListNotifier albumListNotifier;
  final void Function() onClose;
  final void Function(bool visible) onAlbumToggle;

  @override
  State<GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<GalleryHeader> {
  late final _galleryController = context.galleryController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minHeight: _galleryController.slidablePanelSetting.handleBarHeight,
        maxHeight: _galleryController.slidablePanelSetting.headerHeight,
      ),
      color: _galleryController.slidablePanelSetting.headerBackground,
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
                    subtitle: widget.headerSubtitle,
                    albumListNotifier: widget.albumListNotifier,
                    onAlbumToggle: widget.onAlbumToggle,
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
        onPressed: widget.onClose,
      ),
    );
  }

  Widget _buildToggleMultiSelection() {
    if (_galleryController.setting.selectionMode == SelectionMode.countBased) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.centerRight,
      child: GalleryBuilder(
        controller: _galleryController,
        builder: (context, gallery) {
          return CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            onPressed: () {
              if (_galleryController.value.isAlbumVisible) {
                widget.onAlbumToggle(true);
              } else {
                _galleryController.toggleMultiSelection();
              }
            },
            child: Icon(
              CupertinoIcons.square_stack_3d_up,
              size: 28,
              color: gallery.allowMultiple ? _galleryController.setting.theme?.primaryColor : Colors.white38,
            ),
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

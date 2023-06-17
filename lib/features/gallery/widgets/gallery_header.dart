import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/album_builder.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/builder/gallery_builder.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key? key,
    required this.onClose,
    required this.onAlbumListToggle,
    required this.galleryController,
  }) : super(key: key);

  final Function() onClose;
  final Function() onAlbumListToggle;
  final GalleryController galleryController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: galleryController.slidablePanelSetting.headerHeight,
      color: galleryController.slidablePanelSetting.headerBackground,
      child: Column(
        children: [
          Flexible(child: _buildHandleBar()),
          Flexible(
            child: Row(
              children: [
                Expanded(child: _buildCloseButton()),
                FittedBox(
                  child: Row(
                    children: [
                      _buildAlbumInfo(),
                      _buildAnimatedDropdownButton(),
                    ],
                  ),
                ),
                Expanded(child: _buildClearButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    if (galleryController.isFullScreenMode) {
      return SizedBox(height: galleryController.slidablePanelSetting.handleBarHeight);
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

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        minSize: 0,
        child: Text(
          'Cancel',
          style: galleryController.setting.theme?.textTheme.titleSmall?.copyWith(color: Colors.grey.shade700) ??
              TextStyle(fontSize: 16, color: Colors.blue.shade400),
        ),
        onPressed: onClose,
      ),
    );
  }

  Widget _buildClearButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GalleryBuilder(
        controller: galleryController,
        builder: (context, gallery) {
          if (gallery.selectedAssets.isEmpty) return const SizedBox();
          return CupertinoButton(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            minSize: 0,
            child: Text(
              'Clear',
              style: galleryController.setting.theme?.textTheme.titleSmall?.copyWith(color: Colors.grey.shade700) ??
                  TextStyle(fontSize: 16, color: Colors.red.shade400),
            ),
            onPressed: galleryController.clearSelection,
          );
        },
      ),
    );
  }

  Widget _buildAlbumInfo() {
    return GalleryBuilder(
      controller: galleryController,
      builder: (context, gallery) {
        if (gallery.selectedAssets.isNotEmpty) {
          final accessCount = gallery.selectedAssets.length;
          return Text(
            '$accessCount Selected',
            style: galleryController.setting.theme?.textTheme.titleMedium?.copyWith(color: Colors.white) ??
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          );
        }

        final isAlbumVisible = gallery.isAlbumVisible;
        return CurrentAlbumBuilder(
          controller: galleryController.albumListController.currentAlbumController,
          builder: (context, albumController) {
            final isAll = albumController.value.assetPathEntity?.isAll ?? true;
            return Text(
              isAlbumVisible
                  ? 'Select album'
                  : isAll
                      ? galleryController.setting.albumTitle
                      : albumController.value.assetPathEntity?.name ?? 'Unknown',
              style: galleryController.setting.theme?.textTheme.titleMedium?.copyWith(color: Colors.white) ??
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedDropdownButton() {
    return GalleryBuilder(
      controller: galleryController,
      builder: (context, gallery) {
        if (gallery.selectedAssets.isNotEmpty) return const SizedBox();
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(
            begin: gallery.isAlbumVisible ? 0.0 : 1.0,
            end: gallery.isAlbumVisible ? 1.0 : 0.0,
          ),
          builder: (context, factor, child) => Transform.rotate(
            angle: pi * factor,
            child: CupertinoButton(
              minSize: 0,
              padding: const EdgeInsets.all(4),
              child: Icon(CupertinoIcons.chevron_down, size: 20, color: Colors.grey.shade700),
              onPressed: onAlbumListToggle,
            ),
          ),
        );
      },
    );
  }
}

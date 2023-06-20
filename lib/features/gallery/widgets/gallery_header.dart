import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

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

  ColorScheme? get colorScheme => galleryController.setting.colorScheme;
  TextTheme get textTheme => galleryController.setting.textTheme;

  @override
  Widget build(BuildContext context) {
    return SlidablePanelValueBuilder(
      controller: galleryController.slidablePanelController,
      builder: (context, value) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: galleryController.slidablePanelSetting.headerHeight,
          decoration: BoxDecoration(
            color: colorScheme?.surface ?? Colors.black,
            boxShadow: value.status == SlidablePanelStatus.expanded || galleryController.isFullScreenMode
                ? []
                : [BoxShadow(offset: const Offset(0, -1), color: Colors.grey.shade100, blurRadius: 1, spreadRadius: 1)],
          ),
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
      },
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
            width: 36,
            height: 4,
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
          style: textTheme.titleSmall?.copyWith(color: const Color(0xFF66768E)),
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
              style: textTheme.titleSmall?.copyWith(color: const Color(0xFFF43F5E)),
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
            style: textTheme.titleMedium?.copyWith(color: colorScheme?.onSurface ?? Colors.white),
          );
        }

        final isAlbumVisible = gallery.isAlbumVisible;
        return AlbumListBuilder(
          controller: galleryController.albumListController,
          builder: (context, albumList) {
            final currentAlbumController = albumList.currentAlbumController;
            final isAll = currentAlbumController?.value.assetPathEntity?.isAll ?? true;
            return Text(
              isAlbumVisible
                  ? 'Select album'
                  : isAll
                      ? galleryController.setting.albumTitle
                      : currentAlbumController?.value.assetPathEntity?.name ?? 'Unknown',
              style: textTheme.titleMedium?.copyWith(color: colorScheme?.onSurface ?? Colors.white),
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
              padding: const EdgeInsets.all(6),
              child: Icon(
                CupertinoIcons.chevron_down,
                size: 18,
                color: colorScheme?.onSurface ?? Colors.grey.shade700,
              ),
              onPressed: onAlbumListToggle,
            ),
          ),
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key? key,
    required this.onClose,
    required this.onAlbumListToggle,
  }) : super(key: key);

  final Function() onClose;
  final Function() onAlbumListToggle;

  @override
  Widget build(BuildContext context) {
    return SlideSheetValueBuilder(
      controller: GAPManager.slideSheetController,
      builder: (context, value) {
        return Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            minHeight: GAPManager.config.slideSheetConfig.toolbarHeight,
            maxHeight: GAPManager.config.slideSheetConfig.headerHeight,
          ),
          decoration: BoxDecoration(
            color: GAPManager.colorScheme.surface,
            boxShadow: value.status == SlideSheetStatus.expanded || GAPManager.isFullScreenMode
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
    if (GAPManager.isFullScreenMode) return const SizedBox();
    return SizedBox(
      height: GAPManager.slideSheetConfig.handleBarHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 36,
            height: 4,
            color: const Color(0xFFCBCBCB),
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
          style: GAPManager.textTheme.titleSmall?.copyWith(color: const Color(0xFF66768E)),
        ),
        onPressed: onClose,
      ),
    );
  }

  Widget _buildClearButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GalleryBuilder(
        controller: GAPManager.controller,
        builder: (context, gallery) {
          if (gallery.selectedAssets.isEmpty) return const SizedBox();
          return CupertinoButton(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            minSize: 0,
            child: Text(
              'Clear',
              style: GAPManager.textTheme.titleSmall?.copyWith(color: const Color(0xFFF43F5E)),
            ),
            onPressed: GAPManager.controller.clearSelection,
          );
        },
      ),
    );
  }

  Widget _buildAlbumInfo() {
    return GalleryBuilder(
      controller: GAPManager.controller,
      builder: (context, gallery) {
        if (gallery.selectedAssets.isNotEmpty) {
          final accessCount = gallery.selectedAssets.length;
          return Text(
            '$accessCount Selected',
            style: GAPManager.textTheme.titleMedium?.copyWith(color: GAPManager.colorScheme.onSurface),
          );
        }

        final isAlbumVisible = gallery.isAlbumVisible;
        return ValueListenableBuilder<AlbumListValue>(
          valueListenable: GAPManager.albumListController,
          builder: (context, albumList, child) {
            final currentAlbumController = albumList.currentAlbumController;
            final isAll = currentAlbumController?.value.path?.isAll ?? true;
            return Text(
              isAlbumVisible
                  ? 'Select album'
                  : isAll
                      ? GAPManager.config.albumTitle
                      : currentAlbumController?.value.path?.name ?? 'Unknown',
              style: GAPManager.textTheme.titleMedium?.copyWith(color: GAPManager.colorScheme.onSurface),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedDropdownButton() {
    return GalleryBuilder(
      controller: GAPManager.controller,
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
              child: Icon(CupertinoIcons.chevron_down, size: 18, color: GAPManager.colorScheme.onSurface),
              onPressed: onAlbumListToggle,
            ),
          ),
        );
      },
    );
  }
}

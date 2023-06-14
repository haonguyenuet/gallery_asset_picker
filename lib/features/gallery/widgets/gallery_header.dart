import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/albums_controller.dart';
import '../controllers/gallery_controller.dart';
import '../entities/gallery_settings.dart';
import 'albums_builder.dart';
import 'gallery_builder.dart';

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
      constraints: BoxConstraints(
        minHeight: controller.slidablePanelSetting.handleBarHeight,
        maxHeight: controller.slidablePanelSetting.toolbarHeight + controller.slidablePanelSetting.handleBarHeight,
      ),
      color: controller.slidablePanelSetting.headerBackground,
      child: Column(
        children: [
          _Handler(controller: controller),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildCloseButton()),
                FittedBox(
                  child: AlbumDetail(
                    subtitle: headerSubtitle,
                    controller: controller,
                    albumsController: albumsController,
                  ),
                ),
                Expanded(child: _buildControl()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: _IconButton(
        iconData: Icons.close,
        onPressed: onClose,
      ),
    );
  }

  Widget _buildControl() {
    return Row(
      children: [
        const SizedBox(width: 16),
        AnimatedDropdown(
          controller: controller,
          onPressed: onAlbumToggle,
          albumVisibility: controller.albumVisibility,
        ),
        const Spacer(),
        if (controller.setting.selectionMode == SelectionMode.actionBased)
          GalleryBuilder(
            controller: controller,
            builder: (value) {
              return InkWell(
                onTap: () {
                  if (controller.value.isAlbumVisible) {
                    onAlbumToggle(true);
                  } else {
                    controller.toogleMultiSelection();
                  }
                },
                child: Icon(
                  CupertinoIcons.rectangle_stack,
                  color: value.allowMultiple ? Colors.white : Colors.white38,
                ),
              );
            },
          ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class AnimatedDropdown extends StatelessWidget {
  const AnimatedDropdown({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.albumVisibility,
  }) : super(key: key);

  final GalleryController controller;
  final Function(bool visible) onPressed;
  final ValueNotifier<bool> albumVisibility;

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: controller,
      builder: (value) {
        return AnimatedOpacity(
          opacity: value.selectedAssets.isEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
        );
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: albumVisibility,
        builder: (context, visible, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(
              begin: visible ? 0.0 : 1.0,
              end: visible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 300),
            builder: (context, factor, child) {
              return Transform.rotate(angle: pi * factor, child: child);
            },
            child: _IconButton(
              iconData: Icons.keyboard_arrow_down,
              onPressed: () {
                if (controller.value.selectedAssets.isEmpty) {
                  onPressed(visible);
                }
              },
              size: 34,
            ),
          );
        },
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final IconData? iconData;
  final void Function()? onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(40),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          iconData ?? Icons.close,
          color: Colors.lightBlue.shade300,
          size: size ?? 26.0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class AlbumDetail extends StatelessWidget {
  const AlbumDetail({
    Key? key,
    this.subtitle,
    required this.controller,
    required this.albumsController,
  }) : super(key: key);

  final String? subtitle;
  final GalleryController controller;
  final AlbumsController albumsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name
        CurrentAlbumBuilder(
          albumsController: albumsController,
          builder: (context, albumController) {
            final isAll = albumController.value.assetPathEntity?.isAll ?? true;
            return Text(
              isAll ? controller.setting.albumTitle : albumController.value.assetPathEntity?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            );
          },
        ),

        const SizedBox(height: 2),
        // Receiver name
        Text(
          subtitle ?? 'Select',
          style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _Handler extends StatelessWidget {
  const _Handler({
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

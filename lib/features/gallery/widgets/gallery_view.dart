import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modern_media_picker/features/gallery/controllers/album_controller.dart';
import 'package:modern_media_picker/features/gallery/controllers/albums_controller.dart';
import 'package:modern_media_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:modern_media_picker/features/gallery/entities/gallery_settings.dart';
import 'package:modern_media_picker/features/gallery/widgets/albums_page.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_assets_grid_view.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_header.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_select_button.dart';
import 'package:modern_media_picker/widgets/slidable_panel/slidable_panel.dart';

/// [GalleryView] is main ui of package
class GalleryView extends StatefulWidget {
  const GalleryView({Key? key, required this.controller, required this.setting}) : super(key: key);

  final GalleryController controller;
  final GallerySetting setting;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin {
  late final GalleryController _galleryController;
  late final AlbumsController _albumsController;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  double albumHeight = 0;

  SlidablePanelSetting get slidablePanelSetting => widget.setting.slidablePanelSetting;
  bool get isActionMode => _galleryController.setting.selectionMode == SelectionMode.actionBased;

  @override
  void initState() {
    super.initState();
    _galleryController = widget.controller..updateSettings(widget.setting);
    _albumsController = AlbumsController()..fetchAlbums(_galleryController.setting.requestType);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 300),
      value: 0,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _albumsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toogleAlbumList(bool isVisible) {
    if (_animationController.isAnimating) return;
    _galleryController.setAlbumVisibility(visible: !isVisible);
    _galleryController.slidablePanelController.gestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onAlbumChange(AlbumController albumController) {
    if (_animationController.isAnimating) return;
    _albumsController.changeAlbumController(albumController);
    _toogleAlbumList(true);
  }

  Future<bool> _onWillClose() async {
    if (_animationController.isAnimating) return false;
    if (_galleryController.albumVisibility.value) {
      _toogleAlbumList(true);
      return false;
    }
    if (_galleryController.value.selectedAssets.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => _galleryController.setting.closingDialogBuilder?.call() ?? _defaultClosingDialog(),
      );
      return false;
    }
    if (_galleryController.isFullScreenMode) {
      Navigator.of(context).pop();
      return true;
    }
    if (_galleryController.slidablePanelController.isVisible) {
      _galleryController.slidablePanelController.close();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: slidablePanelSetting.overlayStyle,
      child: WillPopScope(
        onWillPop: _onWillClose,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: GalleryHeader(
                  controller: _galleryController,
                  albumsController: _albumsController,
                  onClose: _onWillClose,
                  onAlbumToggle: _toogleAlbumList,
                ),
              ),

              Column(
                children: [
                  if (_galleryController.isFullScreenMode)
                    // Header space for full screen mode
                    SizedBox(height: slidablePanelSetting.headerHeight)
                  else
                    // Toogling size for header hiding animation
                    ValueListenableBuilder<SlidablePanelValue>(
                      valueListenable: _galleryController.slidablePanelController,
                      builder: (context, value, child) {
                        final height = (slidablePanelSetting.headerHeight * value.factor * 1.5).clamp(
                          slidablePanelSetting.handleBarHeight,
                          slidablePanelSetting.headerHeight,
                        );
                        return SizedBox(height: height);
                      },
                    ),
                  Divider(
                    color: _galleryController.setting.theme?.primaryColor ?? Theme.of(context).colorScheme.primary,
                    thickness: 0.5,
                    height: 0.5,
                  ),
                  Expanded(
                    child: GalleryAssetsGridView(
                      controller: _galleryController,
                      albumsController: _albumsController,
                      onClose: _onWillClose,
                    ),
                  ),
                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: GallerySelectButton(controller: _galleryController),
              ),

              // Album list
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final offsetY =
                      slidablePanelSetting.headerHeight + slidablePanelSetting.albumHeight * (1 - _animation.value);
                  return Visibility(
                    visible: _animation.value > 0.0,
                    child: Transform.translate(
                      offset: Offset(0, offsetY),
                      child: AlbumsPage(
                        albumsController: _albumsController,
                        controller: _galleryController,
                        onAlbumChange: _onAlbumChange,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultClosingDialog() {
    return AlertDialog(
      title: const Text(
        'Unselect these items?',
        style: TextStyle(color: Colors.white70),
      ),
      content: Text(
        'Going back will undo the selections you made.',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel', style: TextStyle(color: Colors.lightBlue)),
        ),
        TextButton(
          onPressed: () {
            _galleryController.clearSelection();
            Navigator.of(context).pop();
          },
          child: const Text('Unselect', style: TextStyle(color: Colors.blue)),
        ),
      ],
      backgroundColor: Colors.grey.shade900,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

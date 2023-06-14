import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modern_media_picker/entities/asset_entity_plus.dart';
import 'package:modern_media_picker/features/gallery/controllers/album_controller.dart';
import 'package:modern_media_picker/features/gallery/controllers/albums_controller.dart';
import 'package:modern_media_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:modern_media_picker/features/gallery/entities/gallery_settings.dart';
import 'package:modern_media_picker/features/gallery/widgets/albums_page.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_asset_selector.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_grid_view.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_header.dart';
import 'package:modern_media_picker/features/gallery/widgets/panel_setting_builder.dart';
import 'package:modern_media_picker/utils/ui_handler.dart';
import 'package:modern_media_picker/widgets/animations/page_route.dart';
import 'package:modern_media_picker/widgets/slidable_panel/slidable_panel.dart';

Future<List<AssetEntityPlus>?> pickAssets(
  BuildContext context, {
  GalleryController? controller,
  GallerySetting? setting,
  SlidingRouteSettings? routeSetting,
}) {
  return Navigator.of(context).push<List<AssetEntityPlus>>(
    SlidingPageRoute(
      builder: GalleryView(controller: controller, setting: setting),
      setting: routeSetting ?? const SlidingRouteSettings(settings: RouteSettings(name: GalleryView.name)),
    ),
  );
}

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key, this.controller, this.setting}) : super(key: key);

  final GalleryController? controller;
  final GallerySetting? setting;

  static const String name = 'GalleryView';

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late final GalleryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GalleryController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If [SlidableGallery] is used no need to build panel setting again
    if (!_controller.fullScreenMode) {
      return _View(controller: _controller, setting: widget.setting ?? _controller.setting);
    }

    // Full screen mode
    return PanelSettingBuilder(
      setting: widget.setting?.panelSetting,
      builder: (panelSetting) {
        return _View(
          controller: _controller,
          setting: (widget.setting ?? _controller.setting).copyWith(panelSetting: panelSetting),
        );
      },
    );
  }
}

class _View extends StatefulWidget {
  const _View({Key? key, required this.controller, required this.setting}) : super(key: key);

  final GalleryController controller;
  final GallerySetting setting;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with SingleTickerProviderStateMixin {
  late final GalleryController _controller;
  late final PanelController _panelController;

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final AlbumsController _albumsController;

  double albumHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller..initSettings(setting: widget.setting);
    _albumsController = AlbumsController()..fetchAlbums(_controller.setting.requestType);

    _panelController = _controller.panelController;
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
    _controller.setAlbumVisibility(visible: !isVisible);
    _panelController.isGestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  //
  void _showAlert() {
    final cancel = TextButton(
      onPressed: Navigator.of(context).pop,
      child: Text(
        'CANCEL',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.lightBlue,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: _onSelectionClear,
      child: Text(
        'USELECT ITEMS',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.blue,
            ),
      ),
    );

    final alertDialog = AlertDialog(
      title: Text(
        'Unselect these items?',
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Going back will undo the selections you made.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
    );

    showDialog<void>(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Future<bool> _onClosePressed() async {
    if (_animationController.isAnimating) return false;

    if (_controller.albumVisibility.value) {
      _toogleAlbumList(true);
      return false;
    }

    if (_controller.value.selectedAssets.isNotEmpty) {
      _showAlert();
      return false;
    }

    if (_controller.fullScreenMode) {
      UIHandler.of(context).pop();
      return true;
    }

    if (_panelController.isVisible) {
      if (_panelController.value.status == PanelStatus.max) {
        _panelController.collapse();
      } else {
        _panelController.close();
      }
      return false;
    }
    return true;
  }

  void _onSelectionClear() {
    _controller.clearSelection();
    Navigator.of(context).pop();
  }

  void _onAlbumChange(AlbumController albumController) {
    if (_animationController.isAnimating) return;
    _albumsController.changeAlbumController(albumController);
    _toogleAlbumList(true);
  }

  @override
  Widget build(BuildContext context) {
    final panelSetting = widget.setting.panelSetting;
    final actionMode = _controller.setting.selectionMode == SelectionMode.actionBased;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: panelSetting.overlayStyle,
      child: WillPopScope(
        onWillPop: _onClosePressed,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Header
              Align(
                alignment: Alignment.topCenter,
                child: GalleryHeader(
                  controller: _controller,
                  albumsController: _albumsController,
                  onClose: _onClosePressed,
                  onAlbumToggle: _toogleAlbumList,
                ),
              ),

              // Body
              Column(
                children: [
                  // Header space
                  Builder(
                    builder: (context) {
                      // Header space for full screen mode
                      if (_controller.fullScreenMode) {
                        return SizedBox(height: panelSetting.headerMaxHeight);
                      }

                      // Toogling size for header hiding animation
                      return ValueListenableBuilder<PanelValue>(
                        valueListenable: _panelController,
                        builder: (context, value, child) {
                          final height = (panelSetting.headerMaxHeight * value.factor * 1.2).clamp(
                            panelSetting.handleBarHeight,
                            panelSetting.headerMaxHeight,
                          );
                          return SizedBox(height: height);
                        },
                      );
                    },
                  ),

                  // Divider
                  Divider(
                    color: Colors.lightBlue.shade300,
                    thickness: 0.5,
                    height: 0.5,
                    indent: 0,
                    endIndent: 0,
                  ),

                  // Gallery grid
                  Expanded(
                    child: GalleryGridView(
                      controller: _controller,
                      albumsController: _albumsController,
                      onClosePressed: _onClosePressed,
                    ),
                  ),
                ],
              ),

              // Send and edit button
              if (!actionMode)
                GalleryAssetSelector(
                  controller: _controller,
                  albumsController: _albumsController,
                ),

              // Send button
              // if (actionMode)
              //   Positioned(
              //     bottom: 0,
              //     right: 0,
              //     child: SendButton(controller: _controller),
              //   ),

              // Album list
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final offsetY = panelSetting.headerMaxHeight +
                      (panelSetting.maxHeight! - panelSetting.headerMaxHeight) * (1 - _animation.value);
                  return Visibility(
                    visible: _animation.value > 0.0,
                    child: Transform.translate(
                      offset: Offset(0, offsetY),
                      child: child,
                    ),
                  );
                },
                child: AlbumsPage(
                  albumsController: _albumsController,
                  controller: _controller,
                  onAlbumChange: _onAlbumChange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

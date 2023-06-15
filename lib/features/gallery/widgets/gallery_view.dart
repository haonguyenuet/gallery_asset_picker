import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/album_list_view.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_assets_grid_view.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_header.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_select_button.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/slidable_panel.dart';

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
  late final AlbumListNotifier _albumListNotifier;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  GallerySetting get _gallarySetting => widget.setting;
  SlidablePanelSetting get _slidablePanelSetting => _gallarySetting.slidablePanelSetting;
  bool get isActionMode => _gallarySetting.selectionMode == SelectionMode.actionBased;

  @override
  void initState() {
    super.initState();
    _galleryController = widget.controller..updateSettings(_gallarySetting);
    _albumListNotifier = AlbumListNotifier()..fetchAlbums(_gallarySetting.requestType);

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
    _albumListNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAlbumList(bool isVisible) {
    if (_animationController.isAnimating) return;
    _galleryController.setAlbumVisibility(visible: !isVisible);
    _galleryController.slidablePanelController.gestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onAlbumChange(AlbumNotifier albumNotifier) {
    if (_animationController.isAnimating) return;
    _albumListNotifier.changeCurrentAlbumNotifier(albumNotifier);
    _toggleAlbumList(true);
  }

  Future<bool> _onWillClose() async {
    if (_animationController.isAnimating) return false;
    if (_galleryController.albumVisibility.value) {
      _toggleAlbumList(true);
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
      value: _slidablePanelSetting.overlayStyle,
      child: WillPopScope(
        onWillPop: _onWillClose,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildHeader(),
              _buildAssets(),
              _buildSelectButton(),
              _buildAnimatedAlbumList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: GalleryHeader(
        onClose: _onWillClose,
        onAlbumToggle: _toggleAlbumList,
        albumListNotifier: _albumListNotifier,
      ),
    );
  }

  Widget _buildAssets() {
    return Column(
      children: [
        if (_galleryController.isFullScreenMode)
          // Header space for full screen mode
          SizedBox(height: _slidablePanelSetting.headerHeight)
        else
          // Toogling size for header hiding animation
          ValueListenableBuilder<SlidablePanelValue>(
            valueListenable: _galleryController.slidablePanelController,
            builder: (context, value, child) {
              final height = (_slidablePanelSetting.headerHeight * value.factor * 1.5).clamp(
                _slidablePanelSetting.handleBarHeight,
                _slidablePanelSetting.headerHeight,
              );
              return SizedBox(height: height);
            },
          ),
        Divider(color: _galleryController.setting.theme?.primaryColor, thickness: 0.5, height: 0.5),
        Expanded(
          child: GalleryAssetsGridView(
            onClose: _onWillClose,
            albumListNotifier: _albumListNotifier,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectButton() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: GallerySelectButton(),
    );
  }

  Widget _buildAnimatedAlbumList() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offsetY = _slidablePanelSetting.headerHeight + _slidablePanelSetting.albumHeight * (1 - _animation.value);
        return Visibility(
          visible: _animation.value > 0.0,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: AlbumListPage(
              onAlbumChange: _onAlbumChange,
              albumListNotifier: _albumListNotifier,
            ),
          ),
        );
      },
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';

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
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  SlidablePanelSetting get _slidablePanelSetting => _gallarySetting.slidablePanelSetting;
  GallerySetting get _gallarySetting => widget.setting;
  SlidablePanelController get _slidablePanelController => _galleryController.slidablePanelController;
  AlbumListController get _albumListController => _galleryController.albumListController;

  @override
  void initState() {
    super.initState();
    _galleryController = widget.controller..updateSettings(_gallarySetting);
    _albumListController.fetchAlbums(_gallarySetting.requestType);

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
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAlbumList() {
    if (_animationController.isAnimating) return;
    _galleryController.toggleAlbumListVisibility();
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onAlbumChange(AlbumController albumController) {
    if (_animationController.isAnimating) return;
    _albumListController.changeCurrentAlbumController(albumController);
    _toggleAlbumList();
  }

  Future<bool> _onWillClose() async {
    if (_animationController.isAnimating) return false;
    if (_galleryController.value.isAlbumVisible) {
      _toggleAlbumList();
      return false;
    }
    if (_galleryController.value.selectedAssets.isNotEmpty && _gallarySetting.closingDialogBuilder != null) {
      showDialog(
        context: context,
        builder: (context) => _gallarySetting.closingDialogBuilder!.call(),
      );
      return false;
    }
    _galleryController.close(context);
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
        onAlbumListToggle: _toggleAlbumList,
        galleryController: _galleryController,
      ),
    );
  }

  Widget _buildAssets() {
    // Space to reveal the header in below
    final headerSpace = _galleryController.isFullScreenMode
        ? SizedBox(height: _slidablePanelSetting.headerHeight)
        : SlidablePanelValueBuilder(
            controller: _slidablePanelController,
            builder: (context, value) {
              final height = (_slidablePanelSetting.headerHeight * value.factor * 1.2).clamp(
                _slidablePanelSetting.handleBarHeight,
                _slidablePanelSetting.headerHeight,
              );
              return SizedBox(height: height);
            },
          );
    return Column(
      children: [
        headerSpace,
        const Expanded(child: GalleryAssetsGridView()),
      ],
    );
  }

  Widget _buildSelectButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GallerySelectButton(galleryController: _galleryController),
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
            child: AlbumListView(onAlbumChange: _onAlbumChange),
          ),
        );
      },
    );
  }
}

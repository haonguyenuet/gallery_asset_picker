import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

/// [GalleryView] is main ui of package
class GalleryView extends StatefulWidget {
  const GalleryView({Key? key, required this.controller, required this.setting}) : super(key: key);

  final GalleryController controller;
  final GallerySetting setting;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _galleryController = widget.controller..updateSetting(_gallarySetting);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _albumListController.refreshCurrentAlbum();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    if (_galleryController.isFullScreenMode) {
      NavigatorUtils.of(context).pop();
    } else {
      if (_slidablePanelController.panelStatus == SlidablePanelStatus.expanded) {
        _slidablePanelController.collapse();
      } else {
        _slidablePanelController.close();
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final galleryStack = Stack(
      fit: StackFit.expand,
      children: [
        _buildHeader(),
        _buildAssets(),
        _buildSelectButton(),
        _buildAlbumList(),
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _gallarySetting.overlayStyle,
      child: _galleryController.isFullScreenMode
          ? WillPopScope(
              onWillPop: _onWillClose,
              child: Scaffold(
                backgroundColor: _gallarySetting.colorScheme.background,
                body: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: galleryStack,
                ),
              ),
            )
          : galleryStack,
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
    return SlidablePanelValueBuilder(
      controller: _slidablePanelController,
      builder: (context, value) {
        // Space to reveal the header in below
        final headerSpace = _galleryController.isFullScreenMode
            ? _slidablePanelSetting.headerHeight
            : (_slidablePanelSetting.headerHeight * value.factor)
                .clamp(_slidablePanelSetting.handleBarHeight, _slidablePanelSetting.headerHeight);

        return Padding(
          padding: EdgeInsets.only(top: headerSpace),
          child: const GalleryAssetsGridView(),
        );
      },
    );
  }

  Widget _buildSelectButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GallerySelectButton(galleryController: _galleryController),
    );
  }

  Widget _buildAlbumList() {
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

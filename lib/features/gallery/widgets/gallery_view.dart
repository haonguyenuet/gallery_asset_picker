import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

/// [GalleryView] is main ui of package
class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GalleryController _galleryController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _galleryController = GalleryManager.controller..fetchAlbums();
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
      _galleryController.albumListController.refreshCurrentAlbum();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    if (_galleryController.isFullScreenMode) _galleryController.dispose();
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
    _galleryController.albumListController.changeCurrentAlbumController(albumController);
    _toggleAlbumList();
  }

  Future<bool> _onWillClose() async {
    if (_animationController.isAnimating) return false;
    if (_galleryController.value.isAlbumVisible) {
      _toggleAlbumList();
      return false;
    }
    if (_galleryController.value.selectedAssets.isNotEmpty && GalleryManager.config.closingDialogBuilder != null) {
      showDialog(
        context: context,
        builder: (context) => GalleryManager.config.closingDialogBuilder!.call(),
      );
      return false;
    }
    if (_galleryController.isFullScreenMode) {
      NavigatorUtils.of(context).pop();
    } else {
      if (_galleryController.slideSheetController.panelStatus == SlideSheetStatus.expanded) {
        _galleryController.slideSheetController.collapse();
      } else {
        _galleryController.slideSheetController.close();
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
      value: GalleryManager.config.overlayStyle,
      child: _galleryController.isFullScreenMode
          ? WillPopScope(
              onWillPop: _onWillClose,
              child: Scaffold(
                backgroundColor: GalleryManager.config.colorScheme.background,
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
      child: GalleryHeader(onClose: _onWillClose, onAlbumListToggle: _toggleAlbumList),
    );
  }

  Widget _buildAssets() {
    return SlideSheetValueBuilder(
      controller: _galleryController.slideSheetController,
      builder: (context, value) {
        // Space to reveal the header in below
        final headerSpace = _galleryController.isFullScreenMode
            ? GalleryManager.config.slideSheetConfig.toolbarHeight
            : (GalleryManager.config.slideSheetConfig.headerHeight * value.factor).clamp(
                GalleryManager.config.slideSheetConfig.handleBarHeight,
                GalleryManager.config.slideSheetConfig.headerHeight);

        return Padding(
          padding: EdgeInsets.only(top: headerSpace),
          child: const GalleryAssetsGridView(),
        );
      },
    );
  }

  Widget _buildSelectButton() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: GallerySelectButton(),
    );
  }

  Widget _buildAlbumList() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final maxHeight = _galleryController.isFullScreenMode
            ? MediaQuery.of(context).size.height
            : GalleryManager.config.slideSheetConfig.maxHeight!;
        final headerHeight = _galleryController.isFullScreenMode
            ? GalleryManager.config.slideSheetConfig.toolbarHeight
            : GalleryManager.config.slideSheetConfig.headerHeight;
        final albumHeight = maxHeight - headerHeight;
        final offsetY = headerHeight + albumHeight * (1 - _animation.value);
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

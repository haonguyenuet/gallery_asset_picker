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

class _GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    GAPManager.controller.toggleAlbumListVisibility();
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onAlbumChange(AlbumController albumController) {
    if (_animationController.isAnimating) return;
    GAPManager.albumListController.changeCurrentAlbumController(albumController);
    _toggleAlbumList();
  }

  Future<bool> _onWillClose() async {
    if (_animationController.isAnimating) return false;
    if (GAPManager.controller.value.isAlbumVisible) {
      _toggleAlbumList();
      return false;
    }
    if (GAPManager.controller.value.selectedAssets.isNotEmpty &&
        GAPManager.config.closingDialogBuilder != null) {
      showDialog(
        context: context,
        builder: (context) => GAPManager.config.closingDialogBuilder!.call(),
      );
      return false;
    }
    if (GAPManager.isFullScreenMode) {
      NavigatorUtils.of(context).pop();
    } else {
      if (GAPManager.slideSheetController.panelStatus == SlideSheetStatus.expanded) {
        GAPManager.slideSheetController.collapse();
      } else {
        GAPManager.slideSheetController.close();
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
      value: GAPManager.config.overlayStyle,
      child: GAPManager.isFullScreenMode
          ? WillPopScope(
              onWillPop: _onWillClose,
              child: Scaffold(
                backgroundColor: GAPManager.colorScheme.background,
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
      controller: GAPManager.slideSheetController,
      builder: (context, value) {
        // Space to reveal the header in below
        final headerSpace = GAPManager.isFullScreenMode
            ? GAPManager.slideSheetConfig.toolbarHeight
            : (GAPManager.slideSheetConfig.headerHeight * value.factor)
                .clamp(GAPManager.slideSheetConfig.handleBarHeight, GAPManager.slideSheetConfig.headerHeight);

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
        final maxHeight = GAPManager.isFullScreenMode
            ? MediaQuery.of(context).size.height
            : GAPManager.slideSheetConfig.maxHeight!;
        final headerHeight = GAPManager.isFullScreenMode
            ? GAPManager.slideSheetConfig.toolbarHeight
            : GAPManager.slideSheetConfig.headerHeight;
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

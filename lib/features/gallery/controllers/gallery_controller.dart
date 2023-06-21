import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/controllers.dart';
import 'package:gallery_asset_picker/features/gallery/values/values.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryController extends ValueNotifier<GalleryValue> {
  GalleryController() : super(GalleryValue.none());

  int? _maxCount;
  RequestType _requestType = RequestType.image;
  late Completer<List<GalleryAsset>> _selectionTask;
  final GlobalKey slideSheetKey = GlobalKey();
  final SlideSheetController slideSheetController = SlideSheetController();
  final AlbumListController albumListController = AlbumListController();

  bool get reachedMaximumLimit => value.selectedAssets.length == _maxCount;
  bool get singleSelection => _maxCount == 1;

  Future<List<GalleryAsset>> startSelection({required int? maxCount, required RequestType? requestType}) async {
    this._maxCount = maxCount;
    this._requestType = requestType ?? RequestType.image;
    _selectionTask = Completer<List<GalleryAsset>>();
    return _selectionTask.future;
  }

  List<GalleryAsset> completeSelection() {
    final assets = value.selectedAssets;
    value = GalleryValue.none();
    _selectionTask.complete(assets);
    return assets;
  }

  void clearSelection() {
    value = value.copyWith(selectedAssets: []);
  }

  void toggleAlbumListVisibility() {
    value = value.copyWith(isAlbumVisible: !value.isAlbumVisible);
    slideSheetController.gestureEnabled = !value.isAlbumVisible;
  }

  void fetchAlbums() {
    albumListController.fetchAlbums(_requestType);
  }

  void select(GalleryAsset asset) {
    if (singleSelection) {
      value = value.copyWith(selectedAssets: [asset]);
      return;
    }

    final assets = List.of(value.selectedAssets);
    final isSelected = assets.contains(asset);
    if (isSelected) {
      assets.remove(asset);
      value = value.copyWith(selectedAssets: assets);
    } else if (!reachedMaximumLimit) {
      assets.add(asset);
      value = value.copyWith(selectedAssets: assets);
    }

    if (reachedMaximumLimit) {
      return GAPManager.config.onReachMaximum?.call();
    }
  }

  @override
  void dispose() {
    super.dispose();
    albumListController.dispose();
    slideSheetController.dispose();
  }
}

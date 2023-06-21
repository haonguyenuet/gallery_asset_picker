import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_list_value.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumListController extends ValueNotifier<AlbumListValue> {
  AlbumListController() : super(AlbumListValue.none());

  Future<List<GalleryAsset>> fetchRecentAssets({
    int count = 20,
    RequestType? requestType,
    ValueSetter<Exception>? onException,
  }) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albumPaths = await PhotoManager.getAssetPathList(type: requestType ?? RequestType.all);
        if (albumPaths.isEmpty) return [];
        final assets = await albumPaths.singleWhere((album) => album.isAll).getAssetListPaged(page: 0, size: count);
        return assets.map((e) => e.toGalleryAsset).toList();
      } catch (e) {
        debugPrint('Exception fetching recent entities => $e');
        onException?.call(Exception(e));
        return [];
      }
    } else {
      onException?.call(Exception('Permission unavailable!'));
      return [];
    }
  }

  Future<List<AlbumController>> fetchAlbums(RequestType requestType) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albumPaths = await PhotoManager.getAssetPathList(type: requestType);
        final albumControllers = <AlbumController>[];
        for (final albumPath in albumPaths) {
          final assetCount = await albumPath.assetCountAsync;
          final firstAsset = await albumPath.firstAsset;
          albumControllers.add(AlbumController(
            value: AlbumValue(path: albumPath, assetCount: assetCount, firstAsset: firstAsset),
          ));
        }
        value = value.copyWith(
          fetchStatus: FetchStatus.completed,
          albumControllers: albumControllers,
          currentAlbumController: albumControllers.isNotEmpty ? albumControllers.first : null,
        );
        if (value.currentAlbumController != null) {
          value.currentAlbumController?.fetchAssets();
        }
        return albumControllers;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(fetchStatus: FetchStatus.error, error: e.toString());
        return [];
      }
    } else {
      value = value.copyWith(fetchStatus: FetchStatus.unauthorised);
      changeCurrentAlbumController(
        AlbumController(value: const AlbumValue(fetchStatus: FetchStatus.unauthorised)),
        fetchAssets: false,
      );
      return [];
    }
  }

  void changeCurrentAlbumController(AlbumController albumController, {bool fetchAssets = true}) {
    value = value.copyWith(currentAlbumController: albumController);
    if (fetchAssets) albumController.fetchAssets();
  }

  void changeCurrentAlbumControllerToAll() {
    final allPhotoController = value.albumControllers.firstWhereOrNull((e) => e.value.path?.isAll == true);
    if (allPhotoController != null) {
      value = value.copyWith(currentAlbumController: allPhotoController);
    }
  }

  void refreshCurrentAlbum() {
    value.currentAlbumController?.fetchAssets(refresh: true);
  }
}

extension AssetPathEntityExt on AssetPathEntity {
  Future<AssetEntity?> get firstAsset async {
    final assets = await this.getAssetListPaged(page: 0, size: 1);
    if (assets.isEmpty) return null;
    return assets.first;
  }
}

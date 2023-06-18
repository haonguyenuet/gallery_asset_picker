import 'package:flutter/cupertino.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_list_value.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumListController extends ValueNotifier<AlbumListValue> {
  AlbumListController() : super(AlbumListValue.none());

  Future<List<GalleryAsset>> recentAssets({
    int count = 20,
    RequestType? requestType,
    ValueSetter<Exception>? onException,
  }) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: requestType ?? RequestType.all);
        if (albums.isEmpty) return [];
        final assets = await albums.singleWhere((album) => album.isAll).getAssetListPaged(page: 0, size: count);
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
        final albums = await PhotoManager.getAssetPathList(type: requestType);
        final albumControllers = List.generate(albums.length, (index) {
          return AlbumController(value: AlbumValue(assetPathEntity: albums[index]));
        });
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
}

import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';
import '../entities/album_entity.dart';
import '../entities/albums_entity.dart';
import '../enums/fetching_state.dart';
import 'album_controller.dart';

class AlbumsController extends ValueNotifier<AlbumsEntity> {
  AlbumsController()
      : currentAlbumController = ValueNotifier(AlbumController()),
        super(const AlbumsEntity());

  ///
  final ValueNotifier<AlbumController> currentAlbumController;

  /// Fetch recent entities
  Future<List<AssetEntityPlus>> recentAssets({
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
        return assets.map((e) => e.toPlus).toList();
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

  /// Get album list
  Future<List<AlbumController>> fetchAlbums(RequestType requestType) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: requestType);
        // Update album list
        final albumControllers = List.generate(albums.length, (index) {
          final albumController = AlbumController(albumValue: AlbumEntity(assetPathEntity: albums[index]));
          if (index == 0) {
            currentAlbumController.value = albumController;
            albumController.fetchAssets();
          }
          return albumController;
        });
        value = value.copyWith(
          state: AssetFetchingState.completed,
          albumControllers: albumControllers,
        );
        return albumControllers;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(error: e.toString(), state: AssetFetchingState.error);
        return [];
      }
    } else {
      value = value.copyWith(error: 'Permission', state: AssetFetchingState.unauthorised);
      currentAlbumController.value = AlbumController(
        albumValue: const AlbumEntity(state: AssetFetchingState.unauthorised),
      );
      return [];
    }
  }

  void changeAlbumController(AlbumController albumController) {
    currentAlbumController.value = albumController;
    albumController.fetchAssets();
  }

  @override
  void dispose() {
    currentAlbumController.dispose();
    super.dispose();
  }
}

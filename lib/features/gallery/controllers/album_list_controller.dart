import 'package:flutter/cupertino.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_list_value.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumListController extends ValueNotifier<AlbumListValue> {
  AlbumListController() : super(AlbumListValue.none());

  final currentAlbumController = ValueNotifier(AlbumController());

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
        // Update album list
        final albumControllers = List.generate(albums.length, (index) {
          final albumController = AlbumController(album: AlbumValue(assetPathEntity: albums[index]));
          if (index == 0) changeCurrentAlbumController(albumController);
          return albumController;
        });
        value = value.copyWith(fetchStatus: FetchStatus.completed, albumControllers: albumControllers);
        return albumControllers;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(fetchStatus: FetchStatus.error, error: e.toString());
        return [];
      }
    } else {
      value = value.copyWith(fetchStatus: FetchStatus.unauthorised);
      currentAlbumController.value = AlbumController(album: const AlbumValue(fetchStatus: FetchStatus.unauthorised));
      return [];
    }
  }

  void changeCurrentAlbumController(AlbumController albumController) {
    currentAlbumController.value = albumController;
    albumController.fetchAssets();
  }

  @override
  void dispose() {
    currentAlbumController.dispose();
    super.dispose();
  }
}

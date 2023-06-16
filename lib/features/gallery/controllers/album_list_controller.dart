import 'package:flutter/cupertino.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album_list.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumListController extends ValueNotifier<AlbumList> {
  AlbumListController() : super(AlbumList.none());

  final currentAlbumController = ValueNotifier(AlbumController());

  /// Fetch recent entities
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

  /// Get album list
  Future<List<AlbumController>> fetchAlbums(RequestType requestType) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: requestType);
        // Update album list
        final albumControllers = List.generate(albums.length, (index) {
          final albumController = AlbumController(album: Album(assetPathEntity: albums[index]));
          if (index == 0) changeCurrentAlbumController(albumController);
          return albumController;
        });
        value = value.copyWith(fetchState: FetchState.completed, albumControllers: albumControllers);
        return albumControllers;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(fetchState: FetchState.error, error: e.toString());
        return [];
      }
    } else {
      value = value.copyWith(fetchState: FetchState.unauthorised);
      currentAlbumController.value = AlbumController(album: const Album(fetchState: FetchState.unauthorised));
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

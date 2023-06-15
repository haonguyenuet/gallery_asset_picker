import 'package:flutter/cupertino.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album_list.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumListNotifier extends ValueNotifier<AlbumList> {
  AlbumListNotifier() : super(AlbumList.none());

  final currentAlbumNotifier = ValueNotifier(AlbumNotifier());

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
  Future<List<AlbumNotifier>> fetchAlbums(RequestType requestType) async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final albums = await PhotoManager.getAssetPathList(type: requestType);
        // Update album list
        final albumNotifiers = List.generate(albums.length, (index) {
          final albumNotifier = AlbumNotifier(album: Album(assetPathEntity: albums[index]));
          if (index == 0) {
            currentAlbumNotifier.value = albumNotifier;
            albumNotifier.fetchAssets();
          }
          return albumNotifier;
        });
        value = value.copyWith(fetchState: FetchState.completed, albumNotifiers: albumNotifiers);
        return albumNotifiers;
      } catch (e) {
        debugPrint('Exception fetching albums => $e');
        value = value.copyWith(fetchState: FetchState.error, error: e.toString());
        return [];
      }
    } else {
      value = value.copyWith(fetchState: FetchState.unauthorised);
      currentAlbumNotifier.value = AlbumNotifier(album: const Album(fetchState: FetchState.unauthorised));
      return [];
    }
  }

  void changeCurrentAlbumNotifier(AlbumNotifier albumNotifier) {
    currentAlbumNotifier.value = albumNotifier;
    albumNotifier.fetchAssets();
  }

  @override
  void dispose() {
    currentAlbumNotifier.dispose();
    super.dispose();
  }
}

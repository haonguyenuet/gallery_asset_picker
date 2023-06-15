import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/features/gallery/entities/album.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumNotifier extends ValueNotifier<Album> {
  AlbumNotifier({Album? album}) : super(album ?? Album.none());

  int _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final assets = (await value.assetPathEntity?.getAssetListPaged(page: _currentPage, size: 30)) ?? [];
        final updatedAssets = [...value.assets, ...assets];
        ++_currentPage;
        value = value.copyWith(fetchState: FetchState.completed, assets: updatedAssets);
      } catch (e) {
        debugPrint('Exception fetching assets => $e');
        value = value.copyWith(fetchState: FetchState.error, error: e.toString());
      }
    } else {
      value = value.copyWith(fetchState: FetchState.unauthorised);
    }
    return value.assets;
  }

  /// Insert entity into album
  void insert(AssetEntity entity) {
    if (value.assets.isEmpty) return;
    value = value.copyWith(assets: [entity, ...value.assets]);
  }
}

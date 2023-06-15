import 'package:flutter/foundation.dart';
import 'package:modern_media_picker/features/gallery/enums/fetching_state.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/album_entity.dart';

class AlbumController extends ValueNotifier<AlbumEntity> {
  AlbumController({AlbumEntity? album}) : super(album ?? AlbumEntity.none());

  int _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final assets = (await value.assetPathEntity?.getAssetListPaged(page: _currentPage, size: 30)) ?? [];
        final updatedAssets = [...value.assets, ...assets];
        ++_currentPage;
        value = value.copyWith(state: AssetFetchingState.completed, assets: updatedAssets);
      } catch (e) {
        debugPrint('Exception fetching assets => $e');
        value = value.copyWith(state: AssetFetchingState.error, error: e.toString());
      }
    } else {
      value = value.copyWith(state: AssetFetchingState.unauthorised);
    }
    return value.assets;
  }

  /// Insert entity into album
  void insert(AssetEntity entity) {
    if (value.assets.isEmpty) return;
    value = value.copyWith(assets: [entity, ...value.assets]);
  }
}

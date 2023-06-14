import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/album_entity.dart';
import '../enums/fetching_state.dart';

class AlbumController extends ValueNotifier<AlbumEntity> {
  AlbumController({AlbumEntity? albumValue}) : super(albumValue ?? const AlbumEntity());

  var _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final entities = (await value.assetPathEntity?.getAssetListPaged(page: _currentPage, size: 30)) ?? [];

        final updatedEntities = [...value.assets, ...entities];
        ++_currentPage;
        value = value.copyWith(
          state: AssetFetchingState.completed,
          entities: updatedEntities,
        );
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
    value = value.copyWith(entities: [entity, ...value.assets]);
  }
}

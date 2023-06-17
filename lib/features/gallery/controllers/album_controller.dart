import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumController extends ValueNotifier<AlbumValue> {
  AlbumController({AlbumValue? album}) : super(album ?? AlbumValue.none());

  int _currentPage = 0;

  /// Get assets for the current album
  Future<List<AssetEntity>> fetchAssets() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final assets = (await value.assetPathEntity?.getAssetListPaged(page: _currentPage, size: 30)) ?? [];
        final updatedAssets = [...value.assets, ...assets];
        ++_currentPage;
        value = value.copyWith(fetchStatus: FetchStatus.completed, assets: updatedAssets);
      } catch (e) {
        debugPrint('Exception fetching assets => $e');
        value = value.copyWith(fetchStatus: FetchStatus.error, error: e.toString());
      }
    } else {
      value = value.copyWith(fetchStatus: FetchStatus.unauthorised);
    }
    return value.assets;
  }

  /// Insert asset into album
  void insert(AssetEntity asset) {
    if (value.assets.isEmpty) return;
    value = value.copyWith(assets: [asset, ...value.assets]);
  }
}

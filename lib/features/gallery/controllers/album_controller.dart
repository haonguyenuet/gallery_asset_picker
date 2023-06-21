import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_value.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumController extends ValueNotifier<AlbumValue> {
  AlbumController({AlbumValue? value}) : super(value ?? AlbumValue.none());

  final int _pageSize = 30;
  int _pageIndex = 0;

  Future<List<AssetEntity>> fetchAssets({bool refresh = false}) async {
    if (refresh) _pageIndex = 0;

    final state = await PhotoManager.requestPermissionExtend();
    if (state == PermissionState.authorized) {
      try {
        final assets = (await value.path?.getAssetListPaged(page: _pageIndex, size: _pageSize)) ?? [];
        final updatedAssets = refresh ? assets : [...value.assets, ...assets];
        ++_pageIndex;
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


  void insert(AssetEntity asset) {
    if (value.assets.isEmpty) return;
    value = value.copyWith(assets: [asset, ...value.assets]);
  }
}

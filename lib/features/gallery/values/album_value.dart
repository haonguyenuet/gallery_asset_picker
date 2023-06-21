import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumValue {
  const AlbumValue({
    this.path,
    this.firstAsset,
    this.assets = const <AssetEntity>[],
    this.assetCount = 0,
    this.fetchStatus = FetchStatus.fetching,
    this.error,
  });

  final AssetPathEntity? path;
  final AssetEntity? firstAsset;
  final List<AssetEntity> assets;
  final int assetCount;
  final FetchStatus fetchStatus;
  final String? error;

  AlbumValue copyWith({
    AssetPathEntity? path,
    AssetEntity? firstAsset,
    List<AssetEntity>? assets,
    int? assetCount,
    String? error,
    FetchStatus? fetchStatus,
  }) {
    return AlbumValue(
      path: path ?? this.path,
      firstAsset: firstAsset ?? this.firstAsset,
      assets: assets ?? this.assets,
      assetCount: assetCount ?? this.assetCount,
      error: error ?? this.error,
      fetchStatus: fetchStatus ?? this.fetchStatus,
    );
  }

  factory AlbumValue.none() => const AlbumValue();
}

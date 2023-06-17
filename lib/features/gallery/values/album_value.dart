import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumValue {
  const AlbumValue({
    this.assetPathEntity,
    this.assets = const <AssetEntity>[],
    this.fetchStatus = FetchStatus.fetching,
    this.error,
  });

  final AssetPathEntity? assetPathEntity;
  final List<AssetEntity> assets;
  final FetchStatus fetchStatus;
  final String? error;

  AlbumValue copyWith({
    AssetPathEntity? assetPathEntity,
    List<AssetEntity>? assets,
    String? error,
    FetchStatus? fetchStatus,
  }) {
    return AlbumValue(
      assetPathEntity: assetPathEntity ?? this.assetPathEntity,
      assets: assets ?? this.assets,
      error: error ?? this.error,
      fetchStatus: fetchStatus ?? this.fetchStatus,
    );
  }

  factory AlbumValue.none() => const AlbumValue();
}

import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:photo_manager/photo_manager.dart';

class Album {
  const Album({
    this.assetPathEntity,
    this.assets = const <AssetEntity>[],
    this.fetchState = FetchState.fetching,
    this.error,
  });

  final AssetPathEntity? assetPathEntity;
  final List<AssetEntity> assets;
  final FetchState fetchState;
  final String? error;

  Album copyWith({
    AssetPathEntity? assetPathEntity,
    List<AssetEntity>? assets,
    String? error,
    FetchState? fetchState,
  }) {
    return Album(
      assetPathEntity: assetPathEntity ?? this.assetPathEntity,
      assets: assets ?? this.assets,
      error: error ?? this.error,
      fetchState: fetchState ?? this.fetchState,
    );
  }

  factory Album.none() => const Album();
}

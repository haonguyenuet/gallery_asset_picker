import 'package:photo_manager/photo_manager.dart';

import '../enums/fetching_state.dart';

class AlbumEntity {
  const AlbumEntity({
    this.assetPathEntity,
    this.assets = const <AssetEntity>[],
    this.state = AssetFetchingState.fetching,
    this.error,
  });

  final AssetPathEntity? assetPathEntity;
  final List<AssetEntity> assets;
  final AssetFetchingState state;
  final String? error;

  AlbumEntity copyWith({
    AssetPathEntity? assetPathEntity,
    List<AssetEntity>? entities,
    String? error,
    AssetFetchingState? state,
  }) {
    return AlbumEntity(
      assetPathEntity: assetPathEntity ?? this.assetPathEntity,
      assets: entities ?? this.assets,
      error: error ?? this.error,
      state: state ?? this.state,
    );
  }
}

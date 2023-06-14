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
    List<AssetEntity>? assets,
    String? error,
    AssetFetchingState? state,
  }) {
    return AlbumEntity(
      assetPathEntity: assetPathEntity ?? this.assetPathEntity,
      assets: assets ?? this.assets,
      error: error ?? this.error,
      state: state ?? this.state,
    );
  }

  factory AlbumEntity.none() => const AlbumEntity();

  factory AlbumEntity.unauthorised() => const AlbumEntity(state: AssetFetchingState.unauthorised);

  factory AlbumEntity.completed(List<AssetEntity> assets) => AlbumEntity(
        state: AssetFetchingState.completed,
        assets: assets,
      );

  factory AlbumEntity.error(String? error) => AlbumEntity(
        state: AssetFetchingState.error,
        error: error,
      );
}

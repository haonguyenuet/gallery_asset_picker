import '../controllers/album_controller.dart';
import '../enums/fetching_state.dart';

class AlbumsEntity {
  const AlbumsEntity({
    this.albumControllers = const <AlbumController>[],
    this.state = AssetFetchingState.fetching,
    this.error,
  });

  final List<AlbumController> albumControllers;
  final AssetFetchingState state;
  final String? error;

  AlbumsEntity copyWith({
    List<AlbumController>? albumControllers,
    AssetFetchingState? state,
    String? error,
  }) {
    return AlbumsEntity(
      albumControllers: albumControllers ?? this.albumControllers,
      error: error ?? this.error,
      state: state ?? this.state,
    );
  }

  factory AlbumsEntity.none() => const AlbumsEntity();

  factory AlbumsEntity.unauthorised() => const AlbumsEntity(state: AssetFetchingState.unauthorised);

  factory AlbumsEntity.completed(List<AlbumController> albumControllers) => AlbumsEntity(
        state: AssetFetchingState.completed,
        albumControllers: albumControllers,
      );

  factory AlbumsEntity.error(String? error) => AlbumsEntity(
        state: AssetFetchingState.error,
        error: error,
      );
}

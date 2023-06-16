import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';

class AlbumList {
  const AlbumList({
    this.albumControllers = const <AlbumController>[],
    this.fetchState = FetchState.fetching,
    this.error,
  });

  final List<AlbumController> albumControllers;
  final FetchState fetchState;
  final String? error;

  AlbumList copyWith({
    List<AlbumController>? albumControllers,
    FetchState? fetchState,
    String? error,
  }) {
    return AlbumList(
      albumControllers: albumControllers ?? this.albumControllers,
      error: error ?? this.error,
      fetchState: fetchState ?? this.fetchState,
    );
  }

  factory AlbumList.none() => const AlbumList();
}

import 'package:gallery_asset_picker/features/gallery/controllers/album_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';

class AlbumListValue {
  const AlbumListValue({
    this.albumControllers = const <AlbumController>[],
    this.currentAlbumController,
    this.fetchStatus = FetchStatus.fetching,
    this.error,
  });

  final List<AlbumController> albumControllers;
  final AlbumController? currentAlbumController;
  final FetchStatus fetchStatus;
  final String? error;

  AlbumListValue copyWith({
    List<AlbumController>? albumControllers,
    AlbumController? currentAlbumController,
    FetchStatus? fetchStatus,
    String? error,
  }) {
    return AlbumListValue(
      albumControllers: albumControllers ?? this.albumControllers,
      currentAlbumController: currentAlbumController ?? this.currentAlbumController,
      error: error ?? this.error,
      fetchStatus: fetchStatus ?? this.fetchStatus,
    );
  }

  factory AlbumListValue.none() => const AlbumListValue();
}

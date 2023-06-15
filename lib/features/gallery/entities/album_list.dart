import 'package:gallery_asset_picker/features/gallery/controllers/album_notifier.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';

class AlbumList {
  const AlbumList({
    this.albumNotifiers = const <AlbumNotifier>[],
    this.fetchState = FetchState.fetching,
    this.error,
  });

  final List<AlbumNotifier> albumNotifiers;
  final FetchState fetchState;
  final String? error;

  AlbumList copyWith({
    List<AlbumNotifier>? albumNotifiers,
    FetchState? fetchState,
    String? error,
  }) {
    return AlbumList(
      albumNotifiers: albumNotifiers ?? this.albumNotifiers,
      error: error ?? this.error,
      fetchState: fetchState ?? this.fetchState,
    );
  }

  factory AlbumList.none() => const AlbumList();
}

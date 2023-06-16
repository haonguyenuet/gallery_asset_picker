import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';

class Gallery {
  const Gallery({
    this.selectedAssets = const <GalleryAsset>[],
    this.isAlbumVisible = false,
  });

  final List<GalleryAsset> selectedAssets;
  final bool isAlbumVisible;

  Gallery copyWith({
    List<GalleryAsset>? selectedAssets,
    bool? isAlbumVisible,
  }) {
    return Gallery(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
    );
  }

  @override
  bool operator ==(covariant Gallery other) {
    if (identical(this, other)) return true;
    return listEquals(other.selectedAssets, selectedAssets) && other.isAlbumVisible == isAlbumVisible;
  }

  @override
  int get hashCode => selectedAssets.hashCode ^ isAlbumVisible.hashCode;

  factory Gallery.none() => const Gallery();
}

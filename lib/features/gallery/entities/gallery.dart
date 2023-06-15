import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';

class Gallery {
  const Gallery({
    this.selectedAssets = const <GalleryAsset>[],
    this.isAlbumVisible = false,
    this.allowMultiple = false,
  });

  final List<GalleryAsset> selectedAssets;
  final bool isAlbumVisible;
  final bool allowMultiple;

  Gallery copyWith({
    List<GalleryAsset>? selectedAssets,
    bool? isAlbumVisible,
    bool? allowMultiple,
  }) {
    return Gallery(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
      allowMultiple: allowMultiple ?? this.allowMultiple,
    );
  }

  @override
  bool operator ==(covariant Gallery other) {
    if (identical(this, other)) return true;
    return listEquals(other.selectedAssets, selectedAssets) &&
        other.isAlbumVisible == isAlbumVisible &&
        other.allowMultiple == allowMultiple;
  }

  @override
  int get hashCode => selectedAssets.hashCode ^ isAlbumVisible.hashCode ^ allowMultiple.hashCode;

  factory Gallery.none() => const Gallery();
}

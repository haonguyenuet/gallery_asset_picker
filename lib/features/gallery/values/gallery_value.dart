import 'package:flutter/foundation.dart';
import 'package:gallery_asset_picker/entities/gallery_asset.dart';

@immutable
class GalleryValue {
  const GalleryValue({
    this.selectedAssets = const <GalleryAsset>[],
    this.isAlbumVisible = false,
  });

  final List<GalleryAsset> selectedAssets;
  final bool isAlbumVisible;

  GalleryValue copyWith({
    List<GalleryAsset>? selectedAssets,
    bool? isAlbumVisible,
  }) {
    return GalleryValue(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
    );
  }

  @override
  bool operator ==(covariant GalleryValue other) {
    if (identical(this, other)) return true;
    return listEquals(other.selectedAssets, selectedAssets) && other.isAlbumVisible == isAlbumVisible;
  }

  @override
  int get hashCode => selectedAssets.hashCode ^ isAlbumVisible.hashCode;

  factory GalleryValue.none() => const GalleryValue();
}

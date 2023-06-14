// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:flutter/foundation.dart';

import '../../../entities/asset_entity_plus.dart';

class GalleryEntity {
  const GalleryEntity({
    this.selectedAssets = const <AssetEntityPlus>[],
    this.isAlbumVisible = false,
    this.allowMultiple = false,
  });

  final List<AssetEntityPlus> selectedAssets;
  final bool isAlbumVisible;
  final bool allowMultiple;

  GalleryEntity copyWith({
    List<AssetEntityPlus>? selectedAssets,
    bool? isAlbumVisible,
    bool? allowMultiple,
  }) {
    return GalleryEntity(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
      allowMultiple: allowMultiple ?? this.allowMultiple,
    );
  }

  @override
  bool operator ==(covariant GalleryEntity other) {
    if (identical(this, other)) return true;
    return listEquals(other.selectedAssets, selectedAssets) &&
        other.isAlbumVisible == isAlbumVisible &&
        other.allowMultiple == allowMultiple;
  }

  @override
  int get hashCode => selectedAssets.hashCode ^ isAlbumVisible.hashCode ^ allowMultiple.hashCode;

  factory GalleryEntity.none() => const GalleryEntity();
}

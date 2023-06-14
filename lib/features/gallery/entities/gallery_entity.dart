// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:flutter/foundation.dart';

import '../../../entities/asset_entity_plus.dart';

class GalleryEntity {
  const GalleryEntity({
    this.selectedAssets = const <AssetEntityPlus>[],
    this.isAlbumVisible = false,
    this.enableMultiSelection = false,
  });

  final List<AssetEntityPlus> selectedAssets;
  final bool isAlbumVisible;
  final bool enableMultiSelection;

  GalleryEntity copyWith({
    List<AssetEntityPlus>? selectedAssets,
    bool? isAlbumVisible,
    bool? enableMultiSelection,
  }) {
    return GalleryEntity(
      selectedAssets: selectedAssets ?? this.selectedAssets,
      isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
      enableMultiSelection: enableMultiSelection ?? this.enableMultiSelection,
    );
  }

  @override
  bool operator ==(covariant GalleryEntity other) {
    if (identical(this, other)) return true;

    return listEquals(other.selectedAssets, selectedAssets) &&
        other.isAlbumVisible == isAlbumVisible &&
        other.enableMultiSelection == enableMultiSelection;
  }

  @override
  int get hashCode => selectedAssets.hashCode ^ isAlbumVisible.hashCode ^ enableMultiSelection.hashCode;
}

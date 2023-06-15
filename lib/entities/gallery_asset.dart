import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class GalleryAsset extends AssetEntity {
  const GalleryAsset({
    required super.id,
    required super.height,
    required super.width,
    required super.typeInt,
    super.duration,
    super.orientation = 0,
    super.isFavorite = false,
    super.title,
    super.createDateSecond,
    super.modifiedDateSecond,
    super.relativePath,
    super.latitude,
    super.longitude,
    super.mimeType,
    super.subtype = 0,
    this.pickedThumbData,
    this.pickedFile,
  });

  /// Thumb bytes of image and video. Dont use this for other asset types.
  final Uint8List? pickedThumbData;

  ///  asset is stored
  final File? pickedFile;

  @override
  GalleryAsset copyWith({
    Uint8List? pickedThumbData,
    File? pickedFile,
    String? id,
    int? typeInt,
    int? width,
    int? height,
    int? duration,
    int? orientation,
    bool? isFavorite,
    String? title,
    int? createDateSecond,
    int? modifiedDateSecond,
    String? relativePath,
    double? latitude,
    double? longitude,
    String? mimeType,
    int? subtype,
  }) {
    return GalleryAsset(
      pickedThumbData: pickedThumbData ?? this.pickedThumbData,
      pickedFile: pickedFile ?? this.pickedFile,
      id: id ?? this.id,
      typeInt: typeInt ?? this.typeInt,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      orientation: orientation ?? this.orientation,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
      createDateSecond: createDateSecond ?? this.createDateSecond,
      modifiedDateSecond: modifiedDateSecond ?? this.modifiedDateSecond,
      relativePath: relativePath ?? this.relativePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mimeType: mimeType ?? this.mimeType,
      subtype: subtype ?? this.subtype,
    );
  }
}

extension AssetEntityExt on AssetEntity {
  /// Convert [AssetEntity] to [GalleryAsset]
  GalleryAsset get toGalleryAsset => GalleryAsset(
        id: id,
        width: width,
        height: height,
        typeInt: typeInt,
        duration: duration,
        orientation: orientation,
        isFavorite: isFavorite,
        title: title,
        createDateSecond: createDateSecond,
        modifiedDateSecond: modifiedDateSecond,
        relativePath: relativePath,
        latitude: latitude,
        longitude: longitude,
        mimeType: mimeType,
      );
}

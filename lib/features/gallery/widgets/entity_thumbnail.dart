import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../entities/asset_entity_plus.dart';

/// Widget to display [AssetEntityPlus] thumbnail
class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
    this.onBytesGenerated,
  }) : super(key: key);

  final AssetEntityPlus asset;
  final ValueSetter<Uint8List?>? onBytesGenerated;

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();
    if (asset.type == AssetType.image || asset.type == AssetType.video) {
      if (asset.pickedThumbData != null) {
        child = Image.memory(
          asset.pickedThumbData!,
          fit: BoxFit.cover,
        );
      } else {
        child = Image(
          image: _MediaThumbnailProvider(
            asset: asset,
            onBytesLoaded: onBytesGenerated,
          ),
          fit: BoxFit.cover,
        );
      }
    }

    if (asset.type == AssetType.audio) {
      child = const Center(child: Icon(Icons.audiotrack, color: Colors.white));
    }

    if (asset.type == AssetType.other) {
      child = const Center(child: Icon(Icons.file_copy, color: Colors.white));
    }

    if (asset.type == AssetType.video || asset.type == AssetType.audio) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          child,
          Align(
            alignment: Alignment.bottomRight,
            child: _DurationView(duration: asset.duration),
          ),
        ],
      );
    }

    return AspectRatio(aspectRatio: 1, child: child);
  }
}

typedef DecoderCallback = Future<ui.Codec> Function(
  Uint8List buffer, {
  int? cacheWidth,
  int? cacheHeight,
  bool allowUpscaling,
});

/// ImageProvider implementation
@immutable
class _MediaThumbnailProvider extends ImageProvider<_MediaThumbnailProvider> {
  /// Constructor for creating a [_MediaThumbnailProvider]
  const _MediaThumbnailProvider({
    required this.asset,
    this.onBytesLoaded,
  });

  ///
  final AssetEntityPlus asset;
  final ValueSetter<Uint8List?>? onBytesLoaded;

  @override
  ImageStreamCompleter load(_MediaThumbnailProvider key, DecoderCallback decode) => MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: 1,
        informationCollector: () sync* {
          yield ErrorDescription('Id: ${asset.id}');
        },
      );

  Future<ui.Codec> _loadAsync(
    _MediaThumbnailProvider key,
    DecoderCallback decode,
  ) async {
    assert(key == this, 'Checks _MediaThumbnailProvider');
    final bytes = await asset.thumbnailData;
    onBytesLoaded?.call(bytes);
    return decode(bytes!);
  }

  @override
  Future<_MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_MediaThumbnailProvider>(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    // ignore: test_types_in_equals
    final typedOther = other as _MediaThumbnailProvider;
    return asset.id == typedOther.asset.id;
  }

  @override
  int get hashCode => asset.id.hashCode;

  @override
  String toString() => '$_MediaThumbnailProvider("${asset.id}")';
}

class _DurationView extends StatelessWidget {
  const _DurationView({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final int duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.7),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          duration.formatedDuration,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString().padRight(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

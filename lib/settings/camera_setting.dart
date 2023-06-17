import 'package:camera/camera.dart';

class CameraSetting {
  const CameraSetting({
    this.resolutionPreset = ResolutionPreset.high,
    this.imageFormatGroup = ImageFormatGroup.jpeg,
  });

  /// Image resolution. Default value is [ResolutionPreset.high].
  final ResolutionPreset resolutionPreset;

  /// Image format group. Default value is [ImageFormatGroup.jpeg]
  final ImageFormatGroup imageFormatGroup;

  CameraSetting copyWith({
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
  }) {
    return CameraSetting(
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      imageFormatGroup: imageFormatGroup ?? this.imageFormatGroup,
    );
  }
}

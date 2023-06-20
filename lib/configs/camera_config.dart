import 'package:camera/camera.dart';

class CameraConfig {
  const CameraConfig({
    this.resolutionPreset = ResolutionPreset.high,
    this.imageFormatGroup = ImageFormatGroup.jpeg,
  });

  /// Image resolution. Default value is [ResolutionPreset.high].
  final ResolutionPreset resolutionPreset;

  /// Image format group. Default value is [ImageFormatGroup.jpeg]
  final ImageFormatGroup imageFormatGroup;

  CameraConfig copyWith({
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
  }) {
    return CameraConfig(
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      imageFormatGroup: imageFormatGroup ?? this.imageFormatGroup,
    );
  }
}

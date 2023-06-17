import 'package:camera/camera.dart';

class XCameraValue {
  const XCameraValue({
    this.cameraDescription,
    this.cameras = const [],
    this.cameraType = CameraType.normal,
    this.flashMode = FlashMode.off,
    this.isTakingPicture = false,
    this.error,
  });

  final CameraDescription? cameraDescription;
  final List<CameraDescription> cameras;
  final CameraType cameraType;
  final FlashMode flashMode;
  final bool isTakingPicture;
  final CameraException? error;

  CameraLensDirection get lensDirection => cameraDescription?.lensDirection ?? CameraLensDirection.back;
  CameraLensDirection get oppositeLensDirection =>
      lensDirection == CameraLensDirection.back ? CameraLensDirection.front : CameraLensDirection.back;
  bool get hideCameraFlashButton => lensDirection == CameraLensDirection.front;

  XCameraValue copyWith({
    CameraDescription? cameraDescription,
    List<CameraDescription>? cameras,
    CameraType? cameraType,
    FlashMode? flashMode,
    bool? isTakingPicture,
    CameraException? error,
  }) {
    return XCameraValue(
      cameraDescription: cameraDescription ?? this.cameraDescription,
      cameras: cameras ?? this.cameras,
      cameraType: cameraType ?? this.cameraType,
      flashMode: flashMode ?? this.flashMode,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      error: error ?? this.error,
    );
  }
}

enum CameraType {
  normal('Normal'),
  selfi('Selfi');

  const CameraType(this.value);

  final String value;
}

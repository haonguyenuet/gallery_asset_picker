import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/controllers/camera_controller.dart';

class RawCameraView extends StatelessWidget {
  const RawCameraView({Key? key, required this.xCameraController}) : super(key: key);

  final XCameraController xCameraController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scale = 1 / (xCameraController.cameraController!.value.aspectRatio * size.aspectRatio);

        return ClipRect(
          clipper: _Clipper(size),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: CameraPreview(
              xCameraController.cameraController!,
              child: ConstrainedBox(constraints: const BoxConstraints.expand()),
            ),
          ),
        );
      },
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  const _Clipper(this.size);

  final Size size;

  @override
  Rect getClip(Size s) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

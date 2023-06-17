import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/src/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/features/camera/src/values/camera_value.dart';

class CameraBuilder extends StatelessWidget {
  const CameraBuilder({
    Key? key,
    required this.xCameraController,
    required this.builder,
  }) : super(key: key);

  final XCameraController xCameraController;

  final Widget Function(BuildContext context, XCameraValue value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<XCameraValue>(
      valueListenable: xCameraController,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

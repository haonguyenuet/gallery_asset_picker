import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/controllers/camera_controller.dart';

import 'package:gallery_asset_picker/features/camera/widgets/camera_builder.dart';

class CameraRotateButton extends StatelessWidget {
  const CameraRotateButton({Key? key, required this.xCameraController}) : super(key: key);

  final XCameraController xCameraController;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      xCameraController: xCameraController,
      builder: (context, value) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.cameraswitch, color: Colors.white, size: 24),
          ),
          onPressed: () => xCameraController.switchCameraDirection(value.oppositeLensDirection),
        );
      },
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/src/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_builder.dart';

class CameraFlashButton extends StatelessWidget {
  const CameraFlashButton({Key? key, required this.xCameraController}) : super(key: key);

  final XCameraController xCameraController;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      xCameraController: xCameraController,
      builder: (context, value) {
        final isOn = value.flashMode != FlashMode.off;
        return CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          child: Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
            child: Padding(
              padding: EdgeInsets.only(left: isOn ? 8.0 : 0.0),
              child: Icon(
                isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: xCameraController.changeFlashMode,
        );
      },
    );
  }
}

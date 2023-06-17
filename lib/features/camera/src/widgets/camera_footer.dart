import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/src/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_rotate_button.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_type_changer.dart';

class CameraFooter extends StatelessWidget {
  const CameraFooter({
    Key? key,
    required this.xCameraController,
  }) : super(key: key);

  final XCameraController xCameraController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          // Margin
          const SizedBox(width: 8),

          // Camera type scroller
          Expanded(child: CameraTypeChanger(xCameraController: xCameraController)),

          // Switch camera
          CameraRotateButton(xCameraController: xCameraController),
        ],
      ),
    );
  }
}

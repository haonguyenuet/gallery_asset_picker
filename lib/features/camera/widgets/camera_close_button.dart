import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/navigator_utils.dart';

class CameraCloseButton extends StatelessWidget {
  const CameraCloseButton({
    Key? key,
    required this.xCameraController,
  }) : super(key: key);

  final XCameraController xCameraController;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
        child: const Icon(Icons.clear, color: Colors.white, size: 24),
      ),
      onPressed: NavigatorUtils.of(context).pop,
    );
  }
}

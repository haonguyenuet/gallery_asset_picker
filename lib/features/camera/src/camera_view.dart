import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/features/camera/src/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/cam_controller_provider.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_builder.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_close_button.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_flash_button.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_footer.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/camera_shutter_button.dart';
import 'package:gallery_asset_picker/features/camera/src/widgets/raw_camera_view.dart';
import 'package:gallery_asset_picker/settings/camera_setting.dart';
import 'package:gallery_asset_picker/utils/system_utils.dart';
import 'package:gallery_asset_picker/widgets/gallery_permission_view.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

class CameraView extends StatefulWidget {
  const CameraView({Key? key, required this.controller, required this.setting}) : super(key: key);

  final XCameraController controller;
  final CameraSetting setting;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver, TickerProviderStateMixin {
  late XCameraController _camController;

  @override
  void initState() {
    super.initState();
    SystemUtils.hideStatusBar();
    WidgetsBinding.instance.addObserver(this);
    _camController = widget.controller..updateSetting(setting: widget.setting);
    Future<void>.delayed(_kRouteDuration, _camController.createCamera);
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller && oldWidget.setting != widget.setting) {
      SystemUtils.hideStatusBar();
      _camController = widget.controller..updateSetting(setting: widget.setting);
      _camController.createCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_camController.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      SystemUtils.showStatusBar();
      _camController.cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      SystemUtils.hideStatusBar();
      _camController.createCamera();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    SystemChrome.restoreSystemUIOverlays();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) {
      _camController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraBuilder(
        xCameraController: _camController,
        builder: (context, value) {
          // Camera
          if (_camController.isInitialized) {
            return CamControllerProvider(
              action: _camController,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RawCameraView(xCameraController: _camController),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CameraFooter(xCameraController: _camController),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: CameraCloseButton(xCameraController: _camController),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: CameraFlashButton(xCameraController: _camController),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 64,
                    child: CameraShutterButton(xCameraController: _camController),
                  ),
                ],
              ),
            );
          }

          // Camera permission
          if (value.error != null && value.error!.code == 'cameraPermission') {
            return Container(
              alignment: Alignment.center,
              child: GalleryPermissionView(
                isCamera: true,
                onRefresh: _camController.createCamera,
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

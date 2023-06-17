import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_asset_picker/features/camera/controllers/camera_controller.dart';
import 'package:gallery_asset_picker/features/camera/widgets/camera_builder.dart';
import 'package:gallery_asset_picker/features/camera/widgets/camera_close_button.dart';
import 'package:gallery_asset_picker/features/camera/widgets/camera_flash_button.dart';
import 'package:gallery_asset_picker/features/camera/widgets/camera_rotate_button.dart';
import 'package:gallery_asset_picker/features/camera/widgets/camera_shutter_button.dart';
import 'package:gallery_asset_picker/features/camera/widgets/raw_camera_view.dart';
import 'package:gallery_asset_picker/settings/camera_setting.dart';
import 'package:gallery_asset_picker/utils/system_utils.dart';
import 'package:gallery_asset_picker/widgets/gallery_permission_view.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.controller, required this.setting}) : super(key: key);

  final XCameraController controller;
  final CameraSetting setting;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  late XCameraController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemUtils.hideStatusBar();
    _controller = widget.controller..updateSetting(setting: widget.setting);
    Future.delayed(_kRouteDuration, _controller.createCamera);
  }

  @override
  void didUpdateWidget(covariant CameraPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller && oldWidget.setting != widget.setting) {
      SystemUtils.hideStatusBar();
      _controller = widget.controller..updateSetting(setting: widget.setting);
      _controller.createCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_controller.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      SystemUtils.showStatusBar();
      _controller.cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      SystemUtils.hideStatusBar();
      _controller.createCamera();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraBuilder(
        xCameraController: _controller,
        builder: (context, value) {
          if (value.error != null && value.error!.code == 'cameraPermission') {
            return Center(
              child: GalleryPermissionView(
                isCamera: true,
                onRefresh: _controller.createCamera,
              ),
            );
          }

          if (_controller.isInitialized) {
            return Stack(
              fit: StackFit.expand,
              children: [
                RawCameraView(xCameraController: _controller),
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom,
                  child: CameraRotateButton(xCameraController: _controller),
                ),
                Positioned(
                  left: 16,
                  top: 24 + MediaQuery.of(context).padding.top,
                  child: CameraCloseButton(xCameraController: _controller),
                ),
                Positioned(
                  right: 16,
                  top: 24 + MediaQuery.of(context).padding.top,
                  child: CameraFlashButton(xCameraController: _controller),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 64 + MediaQuery.of(context).padding.bottom,
                  child: CameraShutterButton(xCameraController: _controller),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

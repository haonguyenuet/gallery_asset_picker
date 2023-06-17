import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/src/values/camera_value.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/settings/camera_setting.dart';
import 'package:path/path.dart' as path;

class XCameraController extends ValueNotifier<XCameraValue> {
  XCameraController() : super(const XCameraValue());

  CameraSetting _setting = const CameraSetting();
  CameraController? _cameraController;
  bool _isDisposed = false;

  CameraSetting get setting => _setting;
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  bool get _hasCamera {
    if (!isInitialized) {
      final exception = CameraException('CAMERA_UNVAILABLE', "Couldn't find the camera!");
      value = value.copyWith(error: exception);
      return false;
    }
    return true;
  }

  void updateSetting({CameraSetting? setting}) {
    _setting = setting ?? const CameraSetting();
  }

  void changeCameraType(CameraType type) {
    final canSwitch = type == CameraType.selfi && value.lensDirection != CameraLensDirection.front;
    if (canSwitch) {
      switchCameraDirection(CameraLensDirection.front);
    }
    value = value.copyWith(cameraType: type);
  }

  void switchCameraDirection(CameraLensDirection direction) {
    if (!_hasCamera) return;

    final cameraDescription = value.cameras.firstWhereOrNull((element) => element.lensDirection == direction);
    createCamera(cameraDescription: cameraDescription);
  }

  Future<CameraController?> createCamera({CameraDescription? cameraDescription}) async {
    if (value.error != null) {
      value = value.copyWith();
    }

    var _cameraDescription = cameraDescription ?? value.cameraDescription;
    var _cameras = value.cameras;

    // Fetch camera descriptions if description is not available
    if (_cameraDescription == null) {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraDescription = _cameras[0];
      } else {
        _cameraDescription = const CameraDescription(
          name: 'Simulator',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );
      }
    }

    // create camera controller
    _cameraController = CameraController(
      _cameraDescription,
      setting.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: _setting.imageFormatGroup,
    );

    final controller = _cameraController!;

    // listen controller
    controller.addListener(() {
      if (controller.value.hasError) {
        final error = 'Camera error ${controller.value.errorDescription}';
        final exception = CameraException('createCamera', error);
        value = value.copyWith(error: exception);
        return;
      }
    });

    try {
      await controller.initialize();
      // _controllerNotifier.value = ControllerValue(
      //   controller: controller,
      //   isReady: true,
      // );
      value = value.copyWith(
        cameraDescription: _cameraDescription,
        cameras: _cameras,
      );

      if (controller.description.lensDirection == CameraLensDirection.back) {
        unawaited(controller.setFlashMode(value.flashMode));
      }
    } on CameraException catch (e) {
      value = value.copyWith(error: e);
      return null;
    } catch (e) {
      final exception = CameraException('CREATE_CAMERA', e.toString());
      value = value.copyWith(error: exception);
      return null;
    }
    return controller;
  }

  Future<GalleryAsset?> takePicture(BuildContext context) async {
    if (value.isTakingPicture) return null;

    return await _safeCall(
      callback: () async {
        value = value.copyWith(isTakingPicture: true);

        final navigator = Navigator.of(context);
        final controller = _cameraController!;

        final xFile = await controller.takePicture();
        await controller.setFlashMode(FlashMode.off);
        final file = File(xFile.path);
        final bytes = await file.readAsBytes();
        final asset = await PhotoManager.editor.saveImage(bytes, title: path.basename(file.path));
        if (file.existsSync()) file.deleteSync();

        if (asset != null) {
          if (navigator.mounted) {
            final galleryAsset = asset.toGalleryAsset.copyWith(pickedThumbData: bytes, pickedFile: file);
            navigator.pop([galleryAsset]);
            return galleryAsset;
          }
        } else {
          final exception = CameraException('TAKE_PICTURE', 'Something went wrong! Please try again');
          value = value.copyWith(isTakingPicture: false, error: exception);
        }
      },
      customException: CameraException('TAKE_PICTURE', "Couldn't take picture"),
    );
  }

  Future<void> changeFlashMode() async {
    await _safeCall(
      callback: () async {
        final controller = _cameraController!;
        final mode = controller.value.flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
        value = value.copyWith(flashMode: mode);
        await controller.setFlashMode(mode);
      },
      customException: CameraException('FLASH_MODE', "Couldn't change the flash mode"),
    );
  }

  Future<void> lockUnlockCaptureOrientation() async {
    await _safeCall(
      callback: () async {
        final controller = _cameraController!;
        if (controller.value.isCaptureOrientationLocked) {
          await controller.unlockCaptureOrientation();
        } else {
          await controller.lockCaptureOrientation();
        }
      },
      customException: CameraException('ORIENTATION_LOCK_UNLOCK', "Couldn't change the orientation"),
    );
  }

  Future<dynamic> _safeCall({required Future<dynamic> Function() callback, CameraException? customException}) async {
    if (!_hasCamera) return;

    try {
      return await callback();
    } on CameraException catch (e) {
      value = value.copyWith(error: e);
      return;
    } catch (e) {
      value = value.copyWith(error: customException);
      return;
    }
  }

  @override
  set value(XCameraValue newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _isDisposed = true;
    super.dispose();
  }
}

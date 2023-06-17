import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/exceptions/camera_exceptions.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
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

  Future<CameraController?> createCamera({CameraDescription? description}) async {
    if (value.error != null) {
      value = value.copyWith();
    }

    var cameraDescription = description ?? value.cameraDescription;
    var cameras = value.cameras;

    // Fetch camera descriptions if description is not available
    if (cameraDescription == null) {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraDescription = cameras[0];
      } else {
        cameraDescription = const CameraDescription(
          name: 'Simulator',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );
      }
    }

    // create camera controller
    _cameraController = CameraController(
      cameraDescription,
      setting.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: _setting.imageFormatGroup,
    );
    _cameraController!.addListener(() {
      if (_cameraController?.value.hasError == true) {
        value = value.copyWith(error: CameraExeptions.createCamera);
        return;
      }
    });

    return await _safeCall(
      callback: () async {
        await _cameraController!.initialize();
        value = value.copyWith(cameraDescription: cameraDescription, cameras: cameras);
        if (_cameraController!.description.lensDirection == CameraLensDirection.back) {
          unawaited(_cameraController!.setFlashMode(value.flashMode));
        }
      },
      customException: CameraExeptions.createCamera,
    );
  }

  void switchCameraDirection(CameraLensDirection direction) {
    if (!_hasCamera) return;
    final cameraDescription = value.cameras.firstWhereOrNull((element) => element.lensDirection == direction);
    createCamera(description: cameraDescription);
  }

  Future<GalleryAsset?> takePicture(BuildContext context) async {
    if (value.isTakingPicture) return null;
    return await _safeCall(
      callback: () async {
        value = value.copyWith(isTakingPicture: true);
        final navigator = Navigator.of(context);

        final xFile = await _cameraController!.takePicture();
        await _cameraController!.setFlashMode(FlashMode.off);
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
          final exception = CameraExeptions.takePicture;
          value = value.copyWith(isTakingPicture: false, error: exception);
        }
      },
      onError: () {
        value = value.copyWith(isTakingPicture: false);
      },
      customException: CameraExeptions.takePicture,
    );
  }

  Future<void> toggleFlashMode() async {
    await _safeCall(
      callback: () async {
        final mode = _cameraController!.value.flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
        value = value.copyWith(flashMode: mode);
        await _cameraController!.setFlashMode(mode);
      },
      customException: CameraExeptions.flaseMode,
    );
  }

  Future<dynamic> _safeCall({
    required Future<dynamic> Function() callback,
    CameraException? customException,
    Function()? onError,
  }) async {
    if (!_hasCamera) return;

    try {
      return await callback();
    } on CameraException catch (e) {
      onError?.call();
      debugPrint(e.description);
      value = value.copyWith(error: e);
      return;
    } catch (e) {
      onError?.call();
      debugPrint(customException?.description);
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

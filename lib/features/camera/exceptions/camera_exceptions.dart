import 'package:camera/camera.dart';

class CameraExceptions {
  static final unvailable = CameraException('UNVAILABLE_CAMERA', "Couldn't find the camera!");
  static final createCamera = CameraException('CREATE_CAMERA', "Couldn't create camera");
  static final takePicture = CameraException('TAKE_PICTURE', "Couldn't take picture");
  static final flaseMode = CameraException('FLASH_MODE', "Couldn't change the flash mode");
}

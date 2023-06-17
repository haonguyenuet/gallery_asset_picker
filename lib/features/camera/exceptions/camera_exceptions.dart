import 'package:camera/camera.dart';

class CameraExeptions {
  static final createCamera = CameraException('CREATE_CAMERA', "Couldn't create camera");
  static final takePicture = CameraException('TAKE_PICTURE', "Couldn't take picture");
  static final flaseMode = CameraException('FLASH_MODE', "Couldn't change the flash mode");
}

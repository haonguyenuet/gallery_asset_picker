// ignore_for_file: always_use_package_imports

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/camera_controller.dart';

///
class CamControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [XCameraController] with a subtree.
  const CamControllerProvider({
    Key? key,
    required XCameraController this.action,
    required Widget child,
  }) : super(key: key, child: child);

  /// Creates a subtree without an associated [XCameraController].
  const CamControllerProvider.none({
    Key? key,
    required Widget child,
  })  : action = null,
        super(key: key, child: child);

  /// The [XCameraController] associated with the subtree.
  ///
  final XCameraController? action;

  /// Returns the [XCameraController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [XCameraController] associated with the
  /// given context.
  static XCameraController? of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<CamControllerProvider>();
    return result?.action;
  }

  @override
  bool updateShouldNotify(covariant CamControllerProvider oldWidget) => action != oldWidget.action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<XCameraController>(
        'controller',
        action,
        ifNull: 'no controller',
        showName: false,
      ),
    );
  }
}

///
extension CamControllerProviderExtension on BuildContext {
  /// [XCameraController] instance
  XCameraController? get camController => CamControllerProvider.of(this);
}

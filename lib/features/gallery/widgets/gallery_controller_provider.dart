import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';

class GalleryControllerProvider extends InheritedWidget {
  /// Creates a widget that associates a [GalleryController] with a subtree.
  const GalleryControllerProvider({super.key, required super.child, required this.controller});

  final GalleryController controller;

  static GalleryController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<GalleryControllerProvider>();
    assert(
      result != null,
      'Error: Could not find the GalleryController above this '
      'This happens because you used a `BuildContext` that does not include the provider',
    );
    return result!.controller;
  }

  @override
  bool updateShouldNotify(covariant GalleryControllerProvider oldWidget) => controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<GalleryController>(
        'controller',
        controller,
        ifNull: 'no controller',
        showName: false,
      ),
    );
  }
}

extension GalleryControllerProviderExtension on BuildContext {
  /// [GalleryController] instance
  GalleryController get galleryController => GalleryControllerProvider.of(this);
}

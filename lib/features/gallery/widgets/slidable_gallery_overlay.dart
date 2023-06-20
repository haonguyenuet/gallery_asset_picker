import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/gallery_manager.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

/// [SlidableGalleryOverlay] will wrap around your page and be slideable
class SlidableGalleryOverlay extends StatelessWidget {
  SlidableGalleryOverlay({Key? key, required this.child, required this.controller}) : super(key: key) {
    GalleryManager.updateController(controller);
  }

  final GalleryController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: controller.slideSheetKey,
      child: GalleryControllerProvider(
        controller: controller,
        child: SlideSheetSafeSize(
          config: GalleryManager.config.slideSheetConfig,
          builder: (safeConfig) {
            GalleryManager.updateConfig(GalleryManager.config.copyWith(slideSheetConfig: safeConfig));
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildMainView(context),
                _buildGalleryView(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final slideSheetConfig = GalleryManager.config.slideSheetConfig;
    return KeyboardVisibility(
      onVisibleChanged: (isKeyboardVisible) {
        if (isKeyboardVisible) {
          controller.slideSheetController.close();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.slideSheetController.close();
              },
              child: child,
            ),
          ),
          // White space for panel min height
          SlideSheetValueBuilder(
            controller: controller.slideSheetController,
            builder: (context, value) {
              return SizedBox(
                height: value.visible
                    ? (slideSheetConfig.minHeight! - bottomInset).clamp(0, slideSheetConfig.minHeight!)
                    : 0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryView() {
    return SlideSheet(
      config: GalleryManager.config.slideSheetConfig,
      controller: controller.slideSheetController,
      listener: (context, value) {
        if (!value.visible) controller.clearSelection();
      },
      child: const GalleryView(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_setting_builder.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

/// Your page will navigate to [GalleryPage] when call [pick], like full screen selection mode
class GalleryPage extends StatelessWidget {
  const GalleryPage({Key? key, required this.controller}) : super(key: key);

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return GalleryControllerProvider(
      controller: controller,
      child: SlidablePanelSafeBuilder(
        setting: controller.slidablePanelSetting,
        builder: (safeSetting) {
          return GalleryView(
            controller: controller,
            setting: controller.setting.copyWith(slidablePanelSetting: safeSetting),
          );
        },
      ),
    );
  }
}

/// [SlidableGalleryOverlay] will wrap around your page and be slideable
class SlidableGalleryOverlay extends StatelessWidget {
  const SlidableGalleryOverlay({Key? key, required this.child, required this.controller}) : super(key: key);

  final GalleryController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: controller.slidablePanelKey,
      child: GalleryControllerProvider(
        controller: controller,
        child: SlidablePanelSafeBuilder(
          setting: controller.slidablePanelSetting,
          builder: (safeSetting) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildMainView(context, safeSetting),
                _buildGalleryView(safeSetting),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, SlidablePanelSetting slidablePanelSetting) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return KeyboardVisibility(
      onVisibleChanged: (isKeyboardVisible) {
        if (isKeyboardVisible) {
          controller.slidablePanelController.close();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.slidablePanelController.close();
              },
              child: child,
            ),
          ),
          // White space for panel min height
          SlidablePanelValueBuilder(
            controller: controller.slidablePanelController,
            builder: (context, value) {
              return SizedBox(
                height: value.visible
                    ? (slidablePanelSetting.minHeight! - bottomInset).clamp(0, slidablePanelSetting.minHeight!)
                    : 0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryView(SlidablePanelSetting slidablePanelSetting) {
    return SlidablePanel(
      setting: slidablePanelSetting,
      controller: controller.slidablePanelController,
      listener: (context, value) {
        if (!value.visible) controller.clearSelection();
      },
      child: GalleryView(
        controller: controller,
        setting: controller.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
      ),
    );
  }
}

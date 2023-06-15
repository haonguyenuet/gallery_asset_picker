import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_view.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/slidable_panel.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/slidable_panel_setting_builder.dart';

/// [SlidableGalleryWrapper] will wrap around your page and be slideable
class SlidableGalleryWrapper extends StatelessWidget {
  const SlidableGalleryWrapper({Key? key, required this.child, required this.controller}) : super(key: key);

  final GalleryController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: controller.slidablePanelKey,
      child: GalleryControllerProvider(
        controller: controller,
        child: SlidablePanelSettingBuilder(
          setting: controller.slidablePanelSetting,
          builder: (slidablePanelSetting) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildMainView(context, slidablePanelSetting),
                _buildGalleryView(slidablePanelSetting),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, SlidablePanelSetting slidablePanelSetting) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final focusNode = FocusScope.of(context);
              if (focusNode.hasFocus) {
                focusNode.unfocus();
              }
              controller.slidablePanelController.close();
              controller.clearSelection();
            },
            child: child,
          ),
        ),

        // White space for panel min height
        ValueListenableBuilder<bool>(
          valueListenable: controller.slidablePanelController.visibility,
          builder: (context, isVisible, child) {
            return SizedBox(
              height: viewInsets.bottom == 0 && isVisible ? slidablePanelSetting.minHeight : 0.0,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryView(SlidablePanelSetting slidablePanelSetting) {
    return SlidablePanel(
      setting: slidablePanelSetting,
      controller: controller.slidablePanelController,
      child: GalleryView(
        controller: controller,
        setting: controller.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
      ),
    );
  }
}

/// Your page will navigate to [GalleryPage] when call [pick], like full screen selection mode
class GalleryPage extends StatelessWidget {
  const GalleryPage({Key? key, required this.controller}) : super(key: key);

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return GalleryControllerProvider(
      controller: controller,
      child: SlidablePanelSettingBuilder(
        setting: controller.slidablePanelSetting,
        builder: (slidablePanelSetting) {
          return GalleryView(
            controller: controller,
            setting: controller.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
          );
        },
      ),
    );
  }
}

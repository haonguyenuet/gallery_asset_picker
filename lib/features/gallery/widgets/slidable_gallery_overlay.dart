import 'package:flutter/material.dart';

import '../../../widgets/slidable_panel/slidable_panel_setting_builder.dart';
import '../../../widgets/widgets.dart';
import '../controllers/gallery_controller.dart';
import '../gallery_view.dart';
import 'gallery_controller_provider.dart';

class SlidableGalleryOverlay extends StatefulWidget {
  const SlidableGalleryOverlay({Key? key, required this.child, this.controller}) : super(key: key);

  final GalleryController? controller;
  final Widget child;

  @override
  State<SlidableGalleryOverlay> createState() => _SlidableGalleryOverlayState();
}

class _SlidableGalleryOverlayState extends State<SlidableGalleryOverlay> {
  late final GalleryController _galleryController;
  late final SlidablePanelController _slidablePanelController;

  @override
  void initState() {
    super.initState();
    _galleryController = widget.controller ?? GalleryController();
    _slidablePanelController = _galleryController.slidablePanelController;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _galleryController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _galleryController.slidablePanelKey,
      child: GalleryControllerProvider(
        controller: _galleryController,
        child: SlidablePanelSettingBuilder(
            setting: _galleryController.setting.slidablePanelSetting,
            builder: (panelSetting) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildMainView(panelSetting),
                  _buildGalleryView(panelSetting),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildMainView(SlidablePanelSetting slidablePanelSetting) {
    final showPanel = MediaQuery.of(context).viewInsets.bottom == 0.0;

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
              _slidablePanelController.close();
            },
            child: widget.child,
          ),
        ),

        // Space for panel min height
        ValueListenableBuilder<bool>(
          valueListenable: _slidablePanelController.visibility,
          builder: (context, isVisible, child) {
            return SizedBox(
              height: showPanel && isVisible ? slidablePanelSetting.minHeight : 0.0,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryView(SlidablePanelSetting slidablePanelSetting) {
    return SlidablePanel(
      setting: slidablePanelSetting,
      controller: _slidablePanelController,
      child: Builder(
        builder: (_) => GalleryView(
          controller: _galleryController,
          setting: _galleryController.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modern_media_picker/features/gallery/widgets/panel_setting_builder.dart';

import '../../../widgets/widgets.dart';
import '../controllers/gallery_controller.dart';
import '../gallery_view.dart';
import 'gallery_controller_provider.dart';

class SlidableGallery extends StatefulWidget {
  const SlidableGallery({Key? key, required this.child, this.controller, this.setting}) : super(key: key);

  final GalleryController? controller;
  final PanelSetting? setting;
  final Widget child;

  @override
  State<SlidableGallery> createState() => _SlidableGalleryState();
}

class _SlidableGalleryState extends State<SlidableGallery> {
  late final GalleryController _galleryController;
  late final PanelController _panelController;

  @override
  void initState() {
    super.initState();
    _galleryController = widget.controller ?? GalleryController();
    _panelController = _galleryController.panelController;
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
    final showPanel = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return Material(
      key: _galleryController.slidablePanelKey,
      child: GalleryControllerProvider(
        controller: _galleryController,
        child: PanelSettingBuilder(
            setting: widget.setting,
            builder: (panelSetting) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final focusNode = FocusScope.of(context);
                            if (focusNode.hasFocus) {
                              focusNode.unfocus();
                            }
                            if (_panelController.isVisible) {
                              _galleryController.completeSelection(context);
                            }
                          },
                          child: widget.child,
                        ),
                      ),

                      // Space for panel min height
                      ValueListenableBuilder<bool>(
                        valueListenable: _panelController.panelVisibility,
                        builder: (context, isVisible, child) {
                          return SizedBox(
                            height: showPanel && isVisible ? panelSetting.minHeight : 0.0,
                          );
                        },
                      ),
                    ],
                  ),
                  SlidablePanel(
                    setting: panelSetting,
                    controller: _panelController,
                    child: Builder(
                      builder: (_) => GalleryView(
                        controller: _galleryController,
                        setting: _galleryController.setting.copyWith(panelSetting: panelSetting),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );

    //
  }
}

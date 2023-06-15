import 'package:flutter/material.dart';
import 'package:modern_media_picker/features/gallery/controllers/gallery_controller.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:modern_media_picker/features/gallery/widgets/gallery_view.dart';
import 'package:modern_media_picker/widgets/slidable_panel/slidable_panel.dart';

import '../../widgets/slidable_panel/slidable_panel_setting_builder.dart';

/// [SlidableGalleryWrapper] will wrap around your page and be slideable
class SlidableGalleryWrapper extends StatefulWidget {
  const SlidableGalleryWrapper({Key? key, required this.child, this.controller}) : super(key: key);

  final GalleryController? controller;
  final Widget child;

  @override
  State<SlidableGalleryWrapper> createState() => _SlidableGalleryWrapperState();
}

class _SlidableGalleryWrapperState extends State<SlidableGalleryWrapper> {
  late final GalleryController _controller = widget.controller ?? GalleryController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _controller.slidablePanelKey,
      child: GalleryControllerProvider(
        controller: _controller,
        child: SlidablePanelSettingBuilder(
          setting: _controller.slidablePanelSetting,
          builder: (slidablePanelSetting) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildMainView(slidablePanelSetting),
                _buildGalleryView(slidablePanelSetting),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainView(SlidablePanelSetting slidablePanelSetting) {
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
              _controller.slidablePanelController.close();
              _controller.clearSelection();
            },
            child: widget.child,
          ),
        ),

        // White space for panel min height
        ValueListenableBuilder<bool>(
          valueListenable: _controller.slidablePanelController.visibility,
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
      controller: _controller.slidablePanelController,
      child: GalleryView(
        controller: _controller,
        setting: _controller.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
      ),
    );
  }
}

/// Your page will navigate to [GalleryPage] when call [pick], like full screen selection mode

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key, this.controller}) : super(key: key);

  final GalleryController? controller;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryController _controller = widget.controller ?? GalleryController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GalleryControllerProvider(
      controller: _controller,
      child: SlidablePanelSettingBuilder(
        setting: _controller.slidablePanelSetting,
        builder: (slidablePanelSetting) {
          return GalleryView(
            controller: _controller,
            setting: _controller.setting.copyWith(slidablePanelSetting: slidablePanelSetting),
          );
        },
      ),
    );
  }
}

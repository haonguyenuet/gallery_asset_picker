import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/gallery_manager.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

/// [SlidableGalleryOverlay] will wrap around your page and be slideable
class SlidableGalleryOverlay extends StatefulWidget {
  SlidableGalleryOverlay({Key? key, required this.child, required this.controller}) : super(key: key) {
    GAPManager.updateController(controller);
  }

  final GalleryController controller;
  final Widget child;

  @override
  State<SlidableGalleryOverlay> createState() => _SlidableGalleryOverlayState();
}

class _SlidableGalleryOverlayState extends State<SlidableGalleryOverlay> with WidgetsBindingObserver {
  late final GalleryController _galleryController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _galleryController = widget.controller;
    _galleryController.fetchAlbums();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _galleryController.fetchAlbums();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _galleryController.slideSheetKey,
      child: GalleryControllerProvider(
        controller: _galleryController,
        child: SlideSheetSafeSize(
          config: GAPManager.config.slideSheetConfig,
          builder: (safeConfig) {
            GAPManager.updateConfig(GAPManager.config.copyWith(slideSheetConfig: safeConfig));
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
    final slideSheetConfig = GAPManager.config.slideSheetConfig;
    return KeyboardVisibility(
      onVisibleChanged: (isKeyboardVisible) {
        if (isKeyboardVisible) {
          _galleryController.slideSheetController.close();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final focusScope = FocusScope.of(context);
                if (focusScope.hasFocus) focusScope.unfocus();
                _galleryController.slideSheetController.close();
              },
              child: widget.child,
            ),
          ),
          // White space for panel min height
          SlideSheetValueBuilder(
            controller: _galleryController.slideSheetController,
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
      config: GAPManager.config.slideSheetConfig,
      controller: _galleryController.slideSheetController,
      listener: (context, value) {
        if (!value.visible) _galleryController.clearSelection();
      },
      child: const GalleryView(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/widgets.dart';

class GallerySelectButton extends StatefulWidget {
  const GallerySelectButton({Key? key}) : super(key: key);

  @override
  GallerySelectButtonState createState() => GallerySelectButtonState();
}

class GallerySelectButtonState extends State<GallerySelectButton> with TickerProviderStateMixin {
  late final AnimationController _opacityController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    GAPManager.controller.addListener(_galleryListener);
    _opacityController = AnimationController(vsync: this, duration: duration);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    GAPManager.controller.removeListener(_galleryListener);
    _opacityController.dispose();
    super.dispose();
  }

  void _galleryListener() {
    if (mounted) {
      final assets = GAPManager.controller.value.selectedAssets;
      if (assets.isEmpty) {
        _opacityController.reverse();
      }
      if (assets.isNotEmpty && _opacityController.value == 0.0) {
        _opacityController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: GAPManager.controller,
      builder: (context, gallery) {
        return AnimatedBuilder(
          animation: _opacity,
          builder: (context, child) {
            final isHide = (gallery.selectedAssets.isEmpty && !_opacityController.isAnimating) || _opacity.value == 0.0;
            return isHide ? const SizedBox() : Opacity(opacity: _opacity.value, child: child);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CommonButton(
              label: StringConst.SELECT,
              width: MediaQuery.of(context).size.width,
              backgroundColor: GAPManager.colorScheme.primary,
              onPressed: (context) {
                GAPManager.controller.completeSelection();
                if (GAPManager.isFullScreenMode) {
                  NavigatorUtils.of(context).pop();
                } else {
                  GAPManager.controller.slideSheetController.close();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

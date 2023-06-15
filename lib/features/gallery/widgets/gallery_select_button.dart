import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:gallery_asset_picker/widgets/common_button.dart';

class GallerySelectButton extends StatefulWidget {
  const GallerySelectButton({Key? key}) : super(key: key);

  @override
  GallerySelectButtonState createState() => GallerySelectButtonState();
}

class GallerySelectButtonState extends State<GallerySelectButton> with TickerProviderStateMixin {
  late final GalleryController _galleryController;
  late final AnimationController _opacityController;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _galleryController = context.galleryController;
    _opacityController = AnimationController(vsync: this, duration: duration);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));
    _galleryController.addListener(_galleryControllerListener);
  }

  @override
  void dispose() {
    _galleryController.removeListener(_galleryControllerListener);
    _opacityController.dispose();
    super.dispose();
  }

  void _galleryControllerListener() {
    if (mounted) {
      final assets = _galleryController.value.selectedAssets;
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
      controller: _galleryController,
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
              backgroundColor: _galleryController.setting.theme?.primaryColor,
              onPressed: (context) {
                if (_galleryController.isFullScreenMode) {
                  Navigator.of(context).pop();
                } else {
                  _galleryController.slidablePanelController.close();
                }
                _galleryController.completeSelection();
              },
            ),
          ),
        );
      },
    );
  }
}

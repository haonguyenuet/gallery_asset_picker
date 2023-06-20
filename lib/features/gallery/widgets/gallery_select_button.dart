import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
import 'package:gallery_asset_picker/widgets/common_button.dart';

class GallerySelectButton extends StatefulWidget {
  const GallerySelectButton({Key? key, required this.galleryController}) : super(key: key);

  final GalleryController galleryController;

  @override
  GallerySelectButtonState createState() => GallerySelectButtonState();
}

class GallerySelectButtonState extends State<GallerySelectButton> with TickerProviderStateMixin {
  late final GalleryController _galleryController;
  late final AnimationController _opacityController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _galleryController = widget.galleryController;
    _galleryController.addListener(_galleryListener);
    _opacityController = AnimationController(vsync: this, duration: duration);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _galleryController.removeListener(_galleryListener);
    _opacityController.dispose();
    super.dispose();
  }

  void _galleryListener() {
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
    final colorScheme = _galleryController.setting.colorScheme;
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
              backgroundColor: colorScheme.primary,
              onPressed: (context) {
                _galleryController.completeSelection();
                if (_galleryController.isFullScreenMode) {
                  NavigatorUtils.of(context).pop();
                } else {
                  _galleryController.slidablePanelController.close();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

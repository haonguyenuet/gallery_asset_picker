import 'package:flutter/material.dart';
import 'package:modern_media_picker/utils/const.dart';
import 'package:modern_media_picker/widgets/common_button.dart';

import '../controllers/gallery_controller.dart';
import '../entities/gallery_entity.dart';

class GallerySelectButton extends StatefulWidget {
  const GallerySelectButton({Key? key, required this.controller}) : super(key: key);

  final GalleryController controller;

  @override
  GallerySelectButtonState createState() => GallerySelectButtonState();
}

class GallerySelectButtonState extends State<GallerySelectButton> with TickerProviderStateMixin {
  late final GalleryController _controller = widget.controller;
  late final AnimationController _opacityController;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _opacityController = AnimationController(vsync: this, duration: duration);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));
    _controller.addListener(_galleryControllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_galleryControllerListener);
    _opacityController.dispose();
    super.dispose();
  }

  void _galleryControllerListener() {
    if (mounted) {
      final assets = _controller.value.selectedAssets;
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
    return ValueListenableBuilder<GalleryEntity>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: _opacity,
          builder: (context, child) {
            final isHide = (value.selectedAssets.isEmpty && !_opacityController.isAnimating) || _opacity.value == 0.0;
            return isHide ? const SizedBox() : Opacity(opacity: _opacity.value, child: child);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CommonButton(
              label: StringConst.SELECT,
              width: MediaQuery.of(context).size.width,
              backgroundColor: _controller.setting.theme?.primaryColor,
              onPressed: (context) {
                if (_controller.isFullScreenMode) {
                  Navigator.of(context).pop();
                } else {
                  _controller.slidablePanelController.close();
                }
                _controller.completeSelection();
              },
            ),
          ),
        );
      },
    );
  }
}

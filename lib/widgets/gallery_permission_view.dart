import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:photo_manager/photo_manager.dart';

import '../utils/navigator_utils.dart';

class GalleryPermissionView extends StatefulWidget {
  const GalleryPermissionView({Key? key, this.onRefresh, this.theme, this.isCamera = false}) : super(key: key);

  final VoidCallback? onRefresh;
  final bool isCamera;
  final ThemeData? theme;

  @override
  State<GalleryPermissionView> createState() => _GalleryPermissionViewState();
}

class _GalleryPermissionViewState extends State<GalleryPermissionView> with WidgetsBindingObserver {
  var _setting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _setting) {
      widget.onRefresh?.call();
      _setting = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setting = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.theme?.colorScheme ?? Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: widget.isCamera ? const EdgeInsets.symmetric(horizontal: 32) : null,
      decoration: BoxDecoration(
        borderRadius: widget.isCamera ? BorderRadius.circular(12) : null,
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.isCamera ? StringConst.CAMERA : StringConst.ALBUM} Access',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'We need to access your ${widget.isCamera ? 'camera' : 'album for picking media'}.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isCamera) ...[
                _buildDenyButton(scheme, context),
                const SizedBox(width: 16),
              ],
              _buildAllowButton(scheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDenyButton(ColorScheme scheme, BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.secondary,
        visualDensity: VisualDensity.comfortable,
      ),
      child: const Text(StringConst.DENY_ACCESS),
      onPressed: NavigatorUtils.of(context).pop,
    );
  }

  Widget _buildAllowButton(ColorScheme scheme) {
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.comfortable,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      child: const Text(StringConst.ALLOW_ACCESS),
      onPressed: () {
        PhotoManager.openSetting();
        _setting = true;
      },
    );
  }
}

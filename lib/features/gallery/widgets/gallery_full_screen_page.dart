import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';

class GalleryFullScreenPage extends StatefulWidget {
  const GalleryFullScreenPage({super.key, required this.controller});

  final GalleryController controller;

  @override
  State<GalleryFullScreenPage> createState() => _GalleryFullScreenPageState();
}

class _GalleryFullScreenPageState extends State<GalleryFullScreenPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.fetchAlbums();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.fetchAlbums();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const GalleryView();
  }
}

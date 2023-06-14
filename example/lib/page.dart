import 'package:flutter/material.dart';
import 'package:modern_media_picker/modern_media_picker.dart';

///
class GridViewWidget extends StatelessWidget {
  ///
  const GridViewWidget({
    Key? key,
    required this.controller,
    required this.setting,
  }) : super(key: key);

  final GalleryController controller;
  final GallerySetting setting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InkWell(
          onTap: () async {
            final entities = await controller.pick(
              context,
              setting: setting.copyWith(
                maximumCount: 10,
                albumSubtitle: 'All',
                requestType: RequestType.image,
              ),
            );
          },
          child: const CircleAvatar(
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

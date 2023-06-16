import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/settings/gallery_settings.dart';

///
class GridViewWidget extends StatefulWidget {
  ///
  const GridViewWidget({Key? key}) : super(key: key);

  @override
  State<GridViewWidget> createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  late final GalleryController galleryController;

  @override
  void initState() {
    super.initState();
    galleryController = GalleryController(
      settings: GallerySetting(
        enableCamera: true,
        crossAxisCount: 4,
        maxCount: 2,
        requestType: RequestType.image,
        onReachMaximum: () {},
      ),
    );
  }

  @override
  void dispose() {
    galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableGalleryWrapper(
      controller: galleryController,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white),
        body: Column(
          children: [
            Expanded(
              child: const SizedBox(),
            ),
            Row(
              children: [
                SizedBox(width: 16),
                InkWell(
                  onTap: () async {
                    final entities = await galleryController.open(context);
                    print(entities.length);
                  },
                  child: Icon(Icons.image),
                ),
                SizedBox(width: 16),
                Expanded(child: CupertinoTextField()),
                SizedBox(width: 16),
              ],
            ),
          ],
          // ),
        ),
      ),
    );
  }
}

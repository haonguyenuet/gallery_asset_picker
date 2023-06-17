import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';

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
        crossAxisCount: 3,
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
    return SlidableGalleryOverlay(
      controller: galleryController,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white),
        body: Column(
          children: [
            Expanded(
              child: const SizedBox(),
            ),
            SlidablePanelValueBuilder(
              controller: galleryController.slidablePanelController,
              builder: (context, value) {
                return Padding(
                  padding: EdgeInsets.only(bottom: value.visible ? 16 : 16 + MediaQuery.of(context).padding.bottom),
                  child: Row(
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
                );
              },
            ),
          ],
          // ),
        ),
      ),
    );
  }
}

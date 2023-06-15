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
  final galleryController = GalleryController(
    settings: const GallerySetting(
      enableCamera: true,
      selectionMode: SelectionMode.countBased,
      maxCount: 5,
      requestType: RequestType.image,
    ),
  );

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
        appBar: AppBar(),
        body: ValueListenableBuilder<bool>(
            valueListenable: galleryController.slidablePanelController.visibility,
            builder: (context, isVisible, child) {
              return Padding(
                padding: EdgeInsets.only(bottom: isVisible ? 10 : MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: const SizedBox(),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16),
                        InkWell(
                          onTap: () async {
                            final entities = await galleryController.pick(context);
                          },
                          child: Icon(Icons.image),
                        ),
                        SizedBox(width: 16),
                        Expanded(child: CupertinoTextField()),
                        SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

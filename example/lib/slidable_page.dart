import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';

class SlidablePage extends StatefulWidget {
  const SlidablePage({Key? key}) : super(key: key);

  @override
  State<SlidablePage> createState() => _SlidablePageState();
}

class _SlidablePageState extends State<SlidablePage> {
  late final GalleryController galleryController;
  List<GalleryAsset> selectedAssets = [];

  @override
  void initState() {
    super.initState();
    galleryController = GalleryController(
      settings: GallerySetting(
        enableCamera: true,
        crossAxisCount: 3,
        maxCount: 3,
        requestType: RequestType.image,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
        ),
        onReachMaximum: () {
          Fluttertoast.showToast(
            msg: "You have reached the allowed number of images",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: const Text(
            'Slidable Gallery Demo',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: selectedAssets.isEmpty
                  ? const Center(child: Text('Choose some images'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(4.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemCount: selectedAssets.length,
                      itemBuilder: (context, index) {
                        final asset = selectedAssets[index];
                        return AssetThumbnail(asset: asset);
                      },
                    ),
            ),
            SlidablePanelValueBuilder(
              controller: galleryController.slidablePanelController,
              builder: (context, value) {
                return Padding(
                  padding: EdgeInsets.only(bottom: value.visible ? 8 : 8 + MediaQuery.of(context).padding.bottom),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () async {
                          // ignore: no_leading_underscores_for_local_identifiers
                          final _selectedAssets = await galleryController.open(context);
                          if (_selectedAssets.isNotEmpty) {
                            setState(() {
                              selectedAssets = _selectedAssets;
                            });
                          }
                        },
                        child: const Icon(Icons.insert_photo),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Type a message',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey.shade200),
                        ),
                      ),
                      const SizedBox(width: 16),
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

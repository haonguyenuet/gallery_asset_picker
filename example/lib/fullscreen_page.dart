import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({Key? key}) : super(key: key);

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  List<GalleryAsset> selectedAssets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Full Screen Gallery Demo',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: selectedAssets.isEmpty
                  ? const Center(child: Text('Do something'))
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
            CupertinoButton.filled(
              onPressed: () async {
                // ignore: no_leading_underscores_for_local_identifiers
                final _selectedAssets = await GalleryAssetPicker.pick(context);
                if (_selectedAssets.isNotEmpty) {
                  setState(() {
                    selectedAssets = _selectedAssets;
                  });
                }
              },
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
          ],
          // ),
        ),
      ),
    );
  }
}

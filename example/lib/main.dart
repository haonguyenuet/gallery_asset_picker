import 'package:example/fullscreen_page.dart';
import 'package:example/slidable_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery Asset Picker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    GalleryAssetPicker.initialize(GalleryConfig(
      enableCamera: true,
      crossAxisCount: 3,
      colorScheme: const ColorScheme.light(primary: Colors.blue),
      onReachMaximum: () {
        Fluttertoast.showToast(
          msg: "You have reached the allowed number of images",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () async {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => const FullScreenPage()));
                },
                child: const Text('Full Screen Case'),
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () async {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => const SlidablePage()));
                },
                child: const Text('Slidable Case'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

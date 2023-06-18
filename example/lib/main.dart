import 'package:example/fullscreen_page.dart';
import 'package:example/slidable_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

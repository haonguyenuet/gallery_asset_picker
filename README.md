# Gallery Asset Picker

A gallery picker and camera in one package. The Gallery and Camera views can both be utilized as Flutter widgets

---

## Table of contents

- [Screenshot](#screenshot)
- [Install](#install)
- [Setup](#setup)
- [Usage](#usage)
- [Bugs or Requests](#bugs-or-requests)

---

## Screenshot

Collapse Mode                                      |Expand Mode                                        | Album List
:-------------------------------------------------:|:-------------------------------------------------:|:-------------------------------------------------:
![image1](screenshots/Screenshot_1687092172.png)  |  ![image2](screenshots/Screenshot_1687092370.png) |  ![image3](screenshots/Screenshot_1687092410.png)

---

## Install

### 1. Add dependency

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  gallery_asset_picker: ^latest_version
```

### 2. Import it

Now in your `Dart` code, you can use:

```dart
import 'package:gallery_asset_picker/gallery_asset_picker.dart';
```

---

## Setup

For more details (if needed) you can go through <a href="https://pub.dev/packages/photo_manager">Photo Manager</a> and <a href="https://pub.dev/packages/camera">Camera</a> readme section as well.

### 1. Android

- Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```gradle
minSdkVersion 21
```

- Required permissions: `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `ACCESS_MEDIA_LOCATION`.

- Glide

Android native use glide to create image thumb bytes, version is 4.11.0.

If your other android library use the library, and version is not same, then you need edit your android project's build.gradle.

```gradle
rootProject.allprojects {

    subprojects {
        project.configurations.all {
            resolutionStrategy.eachDependency { details ->
                if (details.requested.group == 'com.github.bumptech.glide'
                        && details.requested.name.contains('glide')) {
                    details.useVersion '4.11.0'
                }
            }
        }
    }
}
```

If you found some warning logs with `Glide` appearing,
then the main project needs an implementation of `AppGlideModule`.
See [Generated API](https://sjudd.github.io/glide/doc/generatedapi.html).

### 2. iOS

Add following content to `info.plist`.

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Replace with your permission description..</string>
<key>NSCameraUsageDescription</key>
<string>Replace with your permission description..</string>
```

---

## Usage

### 1. To make the gallery view sliding, use the `SlidableGalleryOverlay`; otherwise, ignore it

 ```dart
class SlidableGalleryDemo extends StatelessWidget {
  late final GalleryController galleryController;
  
  ...

  @override
  Widget build(BuildContext context) {
    return SlidableGalleryOverlay(
      controller: galleryController,
      child: Scaffold(
        body: ...
      ),
    );
  }
}
```

### 2. `GallerySetting` can be used for more customization while selection, pass it to the controller

```dart
  @override
  void initState() {
    super.initState();
    galleryController = GalleryController(
      settings: GallerySetting(
        enableCamera: true,
        crossAxisCount: 3,
        maxCount: 3,
        requestType: RequestType.image,
        onReachMaximum: () {},
      ),
    );
  }
```

### 3. Using `open()` function on the controller to pick assets

```dart
  ...
  onPressed : () async {
     final selectedAssets = await galleryController.open(context);
  }
  ...
```

### 4. You can use other widgets included in the package, and for a more thorough implementation and modification, browse the example app

---

## Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/haonguyenuet/gallery_asset_picker/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/haonguyenuet/gallery_asset_picker/issues/new?template=feature_request.md) on GitHub and I'll look into it. Pull request are also welcome.

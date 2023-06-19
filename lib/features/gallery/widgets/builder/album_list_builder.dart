import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/controllers/album_list_controller.dart';
import 'package:gallery_asset_picker/features/gallery/enums/fetch_state.dart';
import 'package:gallery_asset_picker/features/gallery/values/album_list_value.dart';
import 'package:gallery_asset_picker/features/gallery/widgets/gallery_controller_provider.dart';
import 'package:gallery_asset_picker/utils/const.dart';
import 'package:gallery_asset_picker/widgets/gallery_permission_view.dart';

typedef AlbumListWidgetBuilder = Widget Function(BuildContext context, AlbumListValue albums);

class AlbumListBuilder extends StatelessWidget {
  const AlbumListBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.hidePermissionView = false,
  }) : super(key: key);

  final AlbumListController controller;
  final AlbumListWidgetBuilder builder;
  final bool hidePermissionView;

  @override
  Widget build(BuildContext context) {
    final galleryController = context.galleryController;
    return ValueListenableBuilder<AlbumListValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.fetchStatus == FetchStatus.unauthorised && value.albumControllers.isEmpty && !hidePermissionView) {
          return GalleryPermissionView(
            onRefresh: () {
              controller.fetchAlbums(galleryController.setting.requestType);
            },
          );
        }

        // No data
        if (value.fetchStatus == FetchStatus.completed && value.albumControllers.isEmpty) {
          return Center(
            child: Text(
              StringConst.NO_ALBUM_AVAILABLE,
              style: TextStyle(
                color: galleryController.setting.colorScheme?.onBackground ?? Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (value.fetchStatus == FetchStatus.error) {
          return Center(
            child: Text(
              StringConst.SOMETHING_WRONG,
              style: TextStyle(
                color: galleryController.setting.colorScheme?.onBackground ?? Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return builder.call(context, value);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/gallery/gallery.dart';
import 'package:gallery_asset_picker/utils/utils.dart';
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
    return ValueListenableBuilder<AlbumListValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.fetchStatus == FetchStatus.unauthorised && value.albumControllers.isEmpty && !hidePermissionView) {
          return GalleryPermissionView(
            onRefresh: GAPManager.controller.fetchAlbums,
          );
        }

        // No data
        if (value.fetchStatus == FetchStatus.completed && value.albumControllers.isEmpty) {
          return Center(
            child: Text(
              StringConst.NO_ALBUM_AVAILABLE,
              style: GAPManager.textTheme.bodyMedium?.copyWith(color: GAPManager.colorScheme.onBackground),
            ),
          );
        }

        if (value.fetchStatus == FetchStatus.error) {
          return Center(
            child: Text(
              StringConst.SOMETHING_WRONG,
              style: GAPManager.textTheme.bodyMedium?.copyWith(color: GAPManager.colorScheme.onBackground),
            ),
          );
        }

        return builder.call(context, value);
      },
    );
  }
}

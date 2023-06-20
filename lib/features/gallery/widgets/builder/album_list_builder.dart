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
    final colorScheme = GalleryManager.config.colorScheme;
    final textTheme = GalleryManager.config.textTheme;
    return ValueListenableBuilder<AlbumListValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.fetchStatus == FetchStatus.unauthorised && value.albumControllers.isEmpty && !hidePermissionView) {
          return GalleryPermissionView(
            onRefresh: GalleryManager.controller.fetchAlbums,
          );
        }

        // No data
        if (value.fetchStatus == FetchStatus.completed && value.albumControllers.isEmpty) {
          return Center(
            child: Text(
              StringConst.NO_ALBUM_AVAILABLE,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
            ),
          );
        }

        if (value.fetchStatus == FetchStatus.error) {
          return Center(
            child: Text(
              StringConst.SOMETHING_WRONG,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
            ),
          );
        }

        return builder.call(context, value);
      },
    );
  }
}

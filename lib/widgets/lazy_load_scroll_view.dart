import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum _LoadingStatus { loading, none }

/// Wrapper around a [Scrollable] which triggers [onEndOfPage]/[onStartOfPage] the Scrollable
/// reaches to the start or end of the view extent.
class LazyLoadScrollView extends StatefulWidget {
  /// Creates a new instance of [LazyLoadScrollView]. The parameter [child]
  /// must be supplied and not null.
  const LazyLoadScrollView({
    Key? key,
    required this.child,
    this.onStartOfPage,
    this.onEndOfPage,
    this.onPageScrollStart,
    this.onPageScrollEnd,
    this.onInBetweenOfPage,
    this.scrollOffset = 100,
  }) : super(key: key);

  /// The [Widget] that this widget watches for changes on
  final Widget child;

  /// Called when the [child] reaches the start of the list
  final AsyncCallback? onStartOfPage;

  /// Called when the [child] reaches the end of the list
  final AsyncCallback? onEndOfPage;

  /// Called when the list scrolling starts
  final VoidCallback? onPageScrollStart;

  /// Called when the list scrolling ends
  final VoidCallback? onPageScrollEnd;

  /// Called every time the [child] is in-between the list
  final VoidCallback? onInBetweenOfPage;

  /// The offset to take into account when triggering [onEndOfPage]/[onStartOfPage] in pixels
  final double scrollOffset;

  @override
  State<StatefulWidget> createState() => _LazyLoadScrollViewState();
}

class _LazyLoadScrollViewState extends State<LazyLoadScrollView> {
  var _loadMoreStatus = _LoadingStatus.none;
  double _scrollPosition = 0;

  bool _onNotification(ScrollNotification notification) {
    if (notification.metrics.axisDirection == AxisDirection.left ||
        notification.metrics.axisDirection == AxisDirection.right) {
      return true;
    }

    if (notification is ScrollStartNotification) {
      if (widget.onPageScrollStart != null) {
        widget.onPageScrollStart?.call();
        return true;
      }
    }
    if (notification is ScrollEndNotification) {
      if (widget.onPageScrollEnd != null) {
        widget.onPageScrollEnd?.call();
        return true;
      }
    }
    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final maxScrollExtent = notification.metrics.maxScrollExtent;
      final minScrollExtent = notification.metrics.minScrollExtent;
      final scrollOffset = widget.scrollOffset;

      if (pixels > (minScrollExtent + scrollOffset) && pixels < (maxScrollExtent - scrollOffset)) {
        if (widget.onInBetweenOfPage != null) {
          widget.onInBetweenOfPage?.call();
          return true;
        }
      }

      final extentBefore = notification.metrics.extentBefore;
      final extentAfter = notification.metrics.extentAfter;
      final scrollingDown = _scrollPosition < pixels;
      _scrollPosition = pixels;

      if (scrollingDown) {
        if (extentAfter <= scrollOffset) {
          _onEndOfPage();
          return true;
        }
      } else {
        if (extentBefore <= scrollOffset) {
          _onStartOfPage();
          return true;
        }
      }
    }
    if (notification is OverscrollNotification) {
      if (notification.overscroll > 0) {
        _onEndOfPage();
      }
      if (notification.overscroll < 0) {
        _onStartOfPage();
      }
      return true;
    }
    return false;
  }

  void _onEndOfPage() {
    if (_loadMoreStatus == _LoadingStatus.none) {
      if (widget.onEndOfPage != null) {
        _loadMoreStatus = _LoadingStatus.loading;
        widget.onEndOfPage?.call().whenComplete(() {
          _loadMoreStatus = _LoadingStatus.none;
        });
      }
    }
  }

  void _onStartOfPage() {
    if (_loadMoreStatus == _LoadingStatus.none) {
      if (widget.onStartOfPage != null) {
        _loadMoreStatus = _LoadingStatus.loading;
        widget.onStartOfPage!().whenComplete(() {
          _loadMoreStatus = _LoadingStatus.none;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: widget.child,
      );
}

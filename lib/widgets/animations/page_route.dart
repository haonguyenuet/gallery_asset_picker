import 'package:flutter/material.dart';

/// Built a slide page transition for the picker.
class SlidingPageRoute<T> extends PageRoute<T> {
  SlidingPageRoute({
    required this.builder,
    this.setting = const SlidingRouteSettings(),
  })  : transitionDuration = setting.transitionDuration,
        reverseTransitionDuration = setting.reverseTransitionDuration,
        super(settings: setting.settings);

  final Widget builder;

  final SlidingRouteSettings setting;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque = true;

  @override
  final bool barrierDismissible = false;

  @override
  final bool maintainState = true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => builder;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reverse = animation.status == AnimationStatus.reverse;

    final tween = Tween(
      begin: reverse ? setting.reverse.reverseOffset : setting.start.offset,
      end: Offset.zero,
    ).chain(CurveTween(curve: setting.curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

/// Settings for sliding route
class SlidingRouteSettings {
  const SlidingRouteSettings({
    this.curve = Curves.easeInOut,
    this.start = TransitionFrom.bottomToTop,
    this.reverse = TransitionFrom.topToBottom,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.reverseTransitionDuration = const Duration(milliseconds: 400),
    this.settings,
  });

  /// Route animation curve
  final Curve curve;

  /// Route transition will start from this location
  final TransitionFrom start;

  /// Reverse route transition will start from this location
  final TransitionFrom reverse;

  /// Transition duration
  final Duration transitionDuration;

  /// Reverse transition duration
  final Duration reverseTransitionDuration;

  /// Route settings
  final RouteSettings? settings;

  ///
  SlidingRouteSettings copyWith({
    Curve? curve,
    TransitionFrom? start,
    TransitionFrom? reverse,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteSettings? settings,
  }) {
    return SlidingRouteSettings(
      curve: curve ?? this.curve,
      start: start ?? this.start,
      reverse: reverse ?? this.reverse,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration ?? this.reverseTransitionDuration,
      settings: settings ?? this.settings,
    );
  }
}

/// Direction from where route transition will occure
enum TransitionFrom { leftToRight, rightToLeft, topToBottom, bottomToTop }

const _bottom = Offset(0, 1);
const _top = Offset(0, -1);
const _right = Offset(1, 0);
const _left = Offset(-1, 0);

extension on TransitionFrom {
  Offset get offset {
    switch (this) {
      case TransitionFrom.bottomToTop:
        return _bottom;
      case TransitionFrom.topToBottom:
        return _top;
      case TransitionFrom.rightToLeft:
        return _right;
      case TransitionFrom.leftToRight:
        return _left;
    }
  }

  Offset get reverseOffset {
    switch (this) {
      case TransitionFrom.bottomToTop:
        return _top;
      case TransitionFrom.topToBottom:
        return _bottom;
      case TransitionFrom.rightToLeft:
        return _left;
      case TransitionFrom.leftToRight:
        return _right;
    }
  }
}

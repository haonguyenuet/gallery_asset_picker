import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';

part 'slidable_panel_controller.dart';
part 'slidable_panel_status.dart';
part 'slidable_panel_value.dart';

class SlidablePanel extends StatefulWidget {
  const SlidablePanel({
    Key? key,
    this.controller,
    this.setting,
    required this.child,
  }) : super(key: key);

  final SlidablePanelSetting? setting;
  final SlidablePanelController? controller;
  final Widget child;

  @override
  SlidablePanelState createState() => SlidablePanelState();
}

class SlidablePanelState extends State<SlidablePanel> with TickerProviderStateMixin {
  late Size _size;
  late double _minHeight;
  late double _maxHeight;
  late double _remainingHeight;
  late SlidablePanelSetting _setting;
  late SlidablePanelController _controller;
  late ScrollController _scrollController;
  late AnimationController _animationController;

  // Tracking pointer velocity for snaping panel
  VelocityTracker? _velocityTracker;

  // Initial position of pointer before scrolling panel to min height.
  Offset _pointerPositionBeforeScrollToMin = Offset.zero;

  // Initial position of pointer
  Offset _pointerPositionInitial = Offset.zero;

  // true, if panel can be scrolled to bottom
  bool _scrollToBottom = false;

  // true, if panel can be scrolled to top
  bool _scrollToTop = false;

  // true, if pointer is above halfway of the screen, false otherwise.
  bool get _aboveHalfWay => _controller.value.factor > (_setting.snapingPoint);

  @override
  void initState() {
    super.initState();
    _setting = widget.setting ?? const SlidablePanelSetting();
    _controller = (widget.controller ?? SlidablePanelController())..init(this);
    _scrollController = _controller.scrollController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.addListener(_animationListener);
  }

  @override
  void dispose() {
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _animationListener() {
    _controller.updateValue(
      SlidablePanelValue(
        factor: _animationController.value,
        status: _aboveHalfWay ? SlidablePanelStatus.expanded : SlidablePanelStatus.collapsed,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerPositionInitial = event.position;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_controller.gestureEnabled || _animationController.isAnimating || !_shouldScroll(event.position.dy)) return;

    _velocityTracker?.addPosition(event.timeStamp, event.position);

    final currStatus = _pointerPositionInitial.dy - event.position.dy < 0.0
        ? SlidablePanelStatus.reverse
        : SlidablePanelStatus.forward;
    final preStatus = _controller.value.status;
    final mediaQuery = MediaQuery.of(context);

    if (!_scrollToTop && preStatus == SlidablePanelStatus.collapsed && currStatus == SlidablePanelStatus.forward) {
      _scrollToTop = (mediaQuery.size.height - event.position.dy) < _minHeight + _setting.handleBarHeight;
    }

    if (!_scrollToBottom && preStatus == SlidablePanelStatus.expanded && currStatus == SlidablePanelStatus.reverse) {
      final atTopEdge = _scrollController.hasClients && _scrollController.offset == 0;

      final headerStartPosition = _size.height - _maxHeight;
      final headerEndPosition = headerStartPosition + _setting.headerHeight;
      final isHandler = event.position.dy >= headerStartPosition && event.position.dy <= headerEndPosition;
      _scrollToBottom = isHandler || atTopEdge;
      if (_scrollToBottom) {
        _pointerPositionBeforeScrollToMin = event.position;
      }
    }

    if (!_scrollToBottom && preStatus == SlidablePanelStatus.collapsed && currStatus == SlidablePanelStatus.reverse) {
      // return _controller.close();
    }

    if (_scrollToTop || _scrollToBottom) {
      final startingPixel =
          event.position.dy - (_scrollToTop ? _setting.handleBarHeight : _pointerPositionBeforeScrollToMin.dy);
      final num remainingPixel = (_remainingHeight - startingPixel).clamp(0.0, _remainingHeight);

      final num factor = (remainingPixel / _remainingHeight).clamp(0.0, 1.0);
      _slideWithPosition(factor as double, currStatus);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_controller.gestureEnabled || _animationController.isAnimating || !_shouldScroll(event.position.dy)) return;

    final velocity = _velocityTracker?.getVelocity();
    if (velocity != null && (_scrollToTop || _scrollToBottom)) {
      final dyVelocity = velocity.pixelsPerSecond.dy;
      final isFling = dyVelocity.abs() > 200.0;
      final endValue = isFling ? (dyVelocity.isNegative ? 1.0 : 0.0) : (_aboveHalfWay ? 1.0 : 0.0);
      _snapToPosition(endValue);
    }

    _scrollToTop = false;
    _scrollToBottom = false;
    _pointerPositionInitial = Offset.zero;
    _pointerPositionBeforeScrollToMin = Offset.zero;
    _velocityTracker = null;
  }

  // If pointer is moved by more than 2 px then only begain
  bool _shouldScroll(double dyCurrent) {
    return (dyCurrent.abs() - _pointerPositionInitial.dy.abs()).abs() > 2.0;
  }

  void _slideWithPosition(double factor, SlidablePanelStatus state) {
    _controller.updateValue(
      SlidablePanelValue(
        factor: factor,
        status: state,
      ),
    );
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 600, ratio: 1.1),
      startValue ?? _controller.value.factor,
      endValue,
      0,
    );
    _animationController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);

        _size = constraints.biggest;
        _maxHeight = _setting.maxHeight ?? _size.height - mediaQuery.padding.top;
        _minHeight = _setting.minHeight ?? _maxHeight * 0.4;
        _remainingHeight = _maxHeight - _minHeight;

        return ValueListenableBuilder<bool>(
          valueListenable: _controller._visibility,
          builder: (context, bool isVisible, child) {
            if (isVisible == false) return const SizedBox();
            return Column(
              children: [
                const Spacer(), // Space between sliding panel and status bar
                ValueListenableBuilder<SlidablePanelValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final height = (_minHeight + (_remainingHeight * value.factor)).clamp(
                      _minHeight,
                      _maxHeight,
                    );
                    return SizedBox(
                      height: height,
                      child: Listener(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        onPointerUp: _onPointerUp,
                        child: widget.child,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

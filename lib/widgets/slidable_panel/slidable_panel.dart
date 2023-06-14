import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

part 'panel_controller.dart';
part 'panel_setting.dart';
part 'panel_status.dart';
part 'panel_value.dart';

class SlidablePanel extends StatefulWidget {
  const SlidablePanel({Key? key, this.controller, this.setting, this.child}) : super(key: key);

  final PanelSetting? setting;
  final PanelController? controller;
  final Widget? child;

  @override
  State<SlidablePanel> createState() => SlidablePanelState();
}

class SlidablePanelState extends State<SlidablePanel> with TickerProviderStateMixin {
  late double _panelMinHeight;
  late double _panelMaxHeight;
  late double _remainingSpace;
  late Size _size;
  late PanelSetting _setting;

  late PanelController _panelController;
  late ScrollController _scrollController;
  late AnimationController _animationController;

  // Tracking pointer velocity for snaping panel
  VelocityTracker? _velocityTracker;

  // Initial position of pointer
  var _pointerInitialPosition = Offset.zero;

  // true, if panel can be scrolled to bottom
  var _scrollToBottom = false;

  // true, if panel can be scrolled to top
  var _scrollToTop = false;

  // Initial position of pointer before scrolling panel to min height.
  var _pointerPositionBeforeScroll = Offset.zero;

  // true, if pointer is above halfway of the screen, false otherwise.
  bool get _aboveHalfWay => _panelController.value.factor > (_setting.snapingPoint);

  @override
  void initState() {
    super.initState();
    _setting = widget.setting ?? const PanelSetting();
    // Initialization of panel controller
    _panelController = (widget.controller ?? PanelController()).._init(this);
    _scrollController = _panelController.scrollController
      ..addListener(() {
        if ((_scrollToTop || _scrollToBottom) && _scrollController.hasClients) {}
      });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        _panelController.attach(
          PanelValue(
            factor: _animationController.value,
            status: _aboveHalfWay ? PanelStatus.max : PanelStatus.min,
          ),
        );
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.controller == null) {
      _panelController.dispose();
    }
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerInitialPosition = event.position;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_panelController.isGestureEnabled) return;

    if (_animationController.isAnimating) return;

    if (!_shouldScroll(event.position.dy)) return;

    _velocityTracker!.addPosition(event.timeStamp, event.position);

    final status = _pointerInitialPosition.dy - event.position.dy < 0.0 ? PanelStatus.reverse : PanelStatus.forward;
    final panelState = _panelController.value.status;
    final mediaQuery = MediaQuery.of(context);

    if (!_scrollToTop && panelState == PanelStatus.min && status == PanelStatus.forward) {
      _scrollToTop = (mediaQuery.size.height - event.position.dy) < _panelMinHeight + _setting.handleBarHeight;
    }

    if (!_scrollToBottom && panelState == PanelStatus.max && status == PanelStatus.reverse) {
      final atTopEdge = _scrollController.hasClients && _scrollController.offset <= 0 && _scrollController.offset > -10;

      final headerStartPosition = _size.height - _panelMaxHeight;
      final headerEndPosition = headerStartPosition + _setting.headerMaxHeight;
      final isHandler = event.position.dy >= headerStartPosition && event.position.dy <= headerEndPosition;
      _scrollToBottom = isHandler || atTopEdge;
      if (_scrollToBottom) {
        _pointerPositionBeforeScroll = event.position;
      }
    }

    if (_scrollToTop || _scrollToBottom) {
      final startingPX =
          event.position.dy - (_scrollToTop ? _setting.handleBarHeight : _pointerPositionBeforeScroll.dy);
      final num remainingPX = (_remainingSpace - startingPX).clamp(0.0, _remainingSpace);

      final num factor = (remainingPX / _remainingSpace).clamp(0.0, 1.0);
      _slidePanelWithPosition(factor as double, status);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_panelController.isGestureEnabled) return;

    if (_animationController.isAnimating) return;

    if (!_shouldScroll(event.position.dy)) return;

    final velocity = _velocityTracker!.getVelocity();

    if (_scrollToTop || _scrollToBottom) {
      final dyVelocity = velocity.pixelsPerSecond.dy;
      final flingPanel = dyVelocity.abs() > 800.0;
      final endValue = flingPanel ? (dyVelocity.isNegative ? 1.0 : 0.0) : (_aboveHalfWay ? 1.0 : 0.0);
      _snapToPosition(endValue);
    }

    _scrollToTop = false;
    _scrollToBottom = false;
    _pointerInitialPosition = Offset.zero;
    _pointerPositionBeforeScroll = Offset.zero;
    _velocityTracker = null;
  }

  // If pointer is moved by more than 2 px then only begain
  bool _shouldScroll(double currentDY) {
    return (currentDY.abs() - _pointerInitialPosition.dy.abs()).abs() > 2.0;
  }

  void _slidePanelWithPosition(double factor, PanelStatus state) {
    _panelController.attach(
      PanelValue(
        factor: factor,
        status: state,
      ),
    );
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 600, ratio: 1.1),
      startValue ?? _panelController.value.factor,
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
        _panelMaxHeight = _setting.maxHeight ?? _size.height - mediaQuery.padding.top;
        _panelMinHeight = _setting.minHeight ?? _panelMaxHeight * 0.4;
        _remainingSpace = _panelMaxHeight - _panelMinHeight;

        return ValueListenableBuilder<bool>(
          valueListenable: _panelController._panelVisibility,
          builder: (context, bool isVisible, child) {
            return isVisible ? child ?? const SizedBox() : const SizedBox();
          },
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  // Space between sliding panel and status bar
                  const Spacer(),

                  // Sliding panel
                  ValueListenableBuilder(
                    valueListenable: _panelController,
                    builder: (context, PanelValue value, child) {
                      final height = (_panelMinHeight + (_remainingSpace * value.factor)).clamp(
                        _panelMinHeight,
                        _panelMaxHeight,
                      );
                      return SizedBox(height: height, child: child);
                    },
                    child: Listener(
                      onPointerDown: _onPointerDown,
                      onPointerMove: _onPointerMove,
                      onPointerUp: _onPointerUp,
                      child: widget.child ?? const SizedBox(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

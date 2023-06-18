import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:gallery_asset_picker/settings/slidable_panel_setting.dart';
import 'package:gallery_asset_picker/widgets/slidable_panel/builder/slidable_panel_value_builder.dart';

part 'slidable_panel_controller.dart';
part 'slidable_panel_status.dart';
part 'slidable_panel_value.dart';

class SlidablePanel extends StatefulWidget {
  const SlidablePanel({
    Key? key,
    this.setting,
    this.listener,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final SlidablePanelController controller;
  final SlidablePanelSetting? setting;
  final Function(BuildContext context, SlidablePanelValue value)? listener;

  @override
  _SlidablePanelState createState() => _SlidablePanelState();
}

class _SlidablePanelState extends State<SlidablePanel> with TickerProviderStateMixin {
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
    _controller = widget.controller.._init(this);
    _scrollController = _controller.scrollController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controller.addListener(_listener);
    _animationController.addListener(_animationListener);
  }

  @override
  void didUpdateWidget(covariant SlidablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.setting != widget.setting) {
      _setting = widget.setting ?? const SlidablePanelSetting();
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _listener() {
    return widget.listener?.call(context, _controller.value);
  }

  void _animationListener() {
    _controller.updateValue(
      SlidablePanelValue(
        factor: _animationController.value,
        status: _aboveHalfWay ? SlidablePanelStatus.expanded : SlidablePanelStatus.collapsed,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent pointer) {
    _pointerPositionInitial = pointer.position;
    _velocityTracker ??= VelocityTracker.withKind(pointer.kind);
  }

  void _onPointerMove(PointerMoveEvent pointer) {
    if (!_controller.gestureEnabled || _animationController.isAnimating || !_shouldScroll(pointer.position.dy)) return;

    _velocityTracker?.addPosition(pointer.timeStamp, pointer.position);

    final currStatus = _pointerPositionInitial.dy - pointer.position.dy < 0.0
        ? SlidablePanelStatus.reverse
        : SlidablePanelStatus.forward;
    final preStatus = _controller.value.status;

    if (!_scrollToTop && preStatus == SlidablePanelStatus.collapsed && currStatus == SlidablePanelStatus.forward) {
      _scrollToTop = (_size.height - pointer.position.dy) < _minHeight;
    }

    if (!_scrollToBottom && preStatus == SlidablePanelStatus.expanded && currStatus == SlidablePanelStatus.reverse) {
      final atTopEdge = _scrollController.hasClients && _scrollController.offset == 0;

      final headerStartPosition = _size.height - _maxHeight;
      final headerEndPosition = headerStartPosition + _setting.headerHeight;
      final isHandler = pointer.position.dy >= headerStartPosition && pointer.position.dy <= headerEndPosition;
      _scrollToBottom = isHandler || atTopEdge;
      if (_scrollToBottom) {
        _pointerPositionBeforeScrollToMin = pointer.position;
      }
    }

    if (_scrollToTop || _scrollToBottom) {
      final startingOffset =
          pointer.position.dy - (_scrollToTop ? _setting.handleBarHeight : _pointerPositionBeforeScrollToMin.dy);
      final num remainingOffset = (_remainingHeight - startingOffset).clamp(0.0, _remainingHeight);
      final num factor = (remainingOffset / _remainingHeight).clamp(0.0, 1.0);
      _snapWithPosition(factor as double, currStatus);
    }

    if (!_scrollToBottom && preStatus == SlidablePanelStatus.collapsed && currStatus == SlidablePanelStatus.reverse) {
      if (pointer.position.dy - _pointerPositionInitial.dy > _setting.headerHeight) {
        return _controller.close();
      }
    }
  }

  void _onPointerUp(PointerUpEvent pointer) {
    if (!_controller.gestureEnabled || _animationController.isAnimating || !_shouldScroll(pointer.position.dy)) return;

    final velocity = _velocityTracker?.getVelocity();
    if (velocity != null && (_scrollToTop || _scrollToBottom)) {
      final dyVelocity = velocity.pixelsPerSecond.dy;
      final isFling = dyVelocity.abs() > 200.0;
      final endFactor = isFling ? (dyVelocity.isNegative ? 1.0 : 0.0) : (_aboveHalfWay ? 1.0 : 0.0);
      _slideToPosition(endFactor);
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

  void _snapWithPosition(double factor, SlidablePanelStatus state) {
    _controller.updateValue(
      SlidablePanelValue(
        factor: factor,
        status: state,
      ),
    );
  }

  void _slideToPosition(double endFactor, {double? startFactor}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 600, ratio: 1.1),
      startFactor ?? _controller.value.factor,
      endFactor,
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

        return SlidablePanelValueBuilder(
          controller: _controller,
          builder: (context, value) {
            return AnimatedSwitcher(
              duration: Duration.zero,
              reverseDuration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => Align(
                alignment: Alignment.bottomCenter,
                child: SizeTransition(sizeFactor: animation, child: child),
              ),
              child: value.visible == false
                  ? const SizedBox()
                  : Column(
                      children: [
                        const Spacer(), // Space between sliding panel and status bar
                        SizedBox(
                          height: (_minHeight + (_remainingHeight * value.factor)).clamp(_minHeight, _maxHeight),
                          child: Listener(
                            onPointerDown: _onPointerDown,
                            onPointerMove: _onPointerMove,
                            onPointerUp: _onPointerUp,
                            child: widget.child,
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

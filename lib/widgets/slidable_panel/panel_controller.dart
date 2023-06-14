part of 'slidable_panel.dart';

class PanelController extends ValueNotifier<PanelValue> {
  PanelController({
    ScrollController? scrollController,
  })  : _scrollController = scrollController ?? ScrollController(),
        _panelVisibility = ValueNotifier(false),
        super(const PanelValue());

  final ScrollController _scrollController;
  final ValueNotifier<bool> _panelVisibility;
  late SlidablePanelState _state;

  void _init(SlidablePanelState state) {
    _state = state;
  }

  bool _gesture = true;
  bool _internal = true;

  ScrollController get scrollController => _scrollController;
  ValueNotifier<bool> get panelVisibility => _panelVisibility;
  PanelStatus get panelStatus => value.status;
  bool get isVisible => _panelVisibility.value;
  bool get isGestureEnabled => _gesture;

  @override
  set value(PanelValue newValue) {
    if (!_internal) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _panelVisibility.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Change gesture status
  set isGestureEnabled(bool isEnable) {
    if (isGestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  void open() {
    _internal = true;
    if (value.status == PanelStatus.min) return;
    value = value.copyWith(
      state: PanelStatus.min,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = true;
    _gesture = true;
    _internal = false;
  }

  void expand() {
    if (value.status == PanelStatus.max) return;
    _state._snapToPosition(1);
  }

  void collapse() {
    if (value.status == PanelStatus.min) return;
    _state._snapToPosition(0);
  }

  void close() {
    if (!isVisible || value.status == PanelStatus.close) return;
    _internal = true;
    value = value.copyWith(
      state: PanelStatus.close,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = false;
    _gesture = false;
    _internal = false;
  }

  void pause() {
    _internal = true;
    if (value.status == PanelStatus.paused) return;
    value = value.copyWith(state: PanelStatus.paused);
    _panelVisibility.value = false;
    _internal = false;
  }

  void attach(PanelValue sliderValue) {
    _internal = true;
    value = value.copyWith(
      factor: sliderValue.factor,
      offset: sliderValue.offset,
      position: sliderValue.position,
      state: sliderValue.status,
    );
    _internal = false;
  }
}

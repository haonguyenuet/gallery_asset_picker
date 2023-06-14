part of 'slidable_panel.dart';

class SlidablePanelController extends ValueNotifier<SlidablePanelValue> {
  SlidablePanelController({
    ScrollController? scrollController,
  })  : _scrollController = scrollController ?? ScrollController(),
        _visibility = ValueNotifier(false),
        super(const SlidablePanelValue());

  late final SlidablePanelState _state;
  final ScrollController _scrollController;
  final ValueNotifier<bool> _visibility;
  bool _gesture = true;

  ScrollController get scrollController => _scrollController;
  ValueNotifier<bool> get visibility => _visibility;
  SlidablePanelStatus get panelStatus => value.status;
  bool get isVisible => _visibility.value;
  bool get gestureEnabled => _gesture;

  @override
  void dispose() {
    _visibility.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void init(SlidablePanelState state) {
    _state = state;
  }

  set gestureEnabled(bool isEnable) {
    if (gestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  void open() {
    if (value.status == SlidablePanelStatus.collapsed) return;
    value = const SlidablePanelValue(
      status: SlidablePanelStatus.collapsed,
      factor: 0,
    );
    _visibility.value = true;
    _gesture = true;
  }

  void expand() {
    if (!isVisible || value.status == SlidablePanelStatus.expanded) return;
    _state._snapToPosition(1);
  }

  void collapse() {
    if (!isVisible || value.status == SlidablePanelStatus.collapsed) return;
    _state._snapToPosition(0);
  }

  void close() {
    if (!isVisible || value.status == SlidablePanelStatus.closed) return;
    value = const SlidablePanelValue(
      status: SlidablePanelStatus.closed,
      factor: 0,
    );
    _visibility.value = false;
    _gesture = false;
  }

  void updateValue(SlidablePanelValue sliderValue) {
    value = value.copyWith(
      factor: sliderValue.factor,
      status: sliderValue.status,
    );
  }
}

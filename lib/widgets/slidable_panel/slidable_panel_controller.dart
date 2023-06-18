part of 'slidable_panel.dart';

class SlidablePanelController extends ValueNotifier<SlidablePanelValue> {
  SlidablePanelController({ScrollController? scrollController})
      : _scrollController = scrollController ?? ScrollController(),
        super(SlidablePanelValue.closed());

  late _SlidablePanelState _state;
  final ScrollController _scrollController;
  bool _gesture = true;

  ScrollController get scrollController => _scrollController;
  SlidablePanelStatus get panelStatus => value.status;
  bool get gestureEnabled => _gesture;

  set gestureEnabled(bool isEnable) {
    if (gestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  void _init(_SlidablePanelState state) {
    _state = state;
  }

  void open() {
    if (value.status == SlidablePanelStatus.collapsed) return;
    value = const SlidablePanelValue(
      status: SlidablePanelStatus.collapsed,
      factor: 0,
    );
    _gesture = true;
  }

  void collapse() {
    if (!value.visible || value.status == SlidablePanelStatus.collapsed) return;
    _state._slideToPosition(0);
  }

  void expand() {
    if (!value.visible || value.status == SlidablePanelStatus.expanded) return;
    _state._slideToPosition(1);
  }

  void close() {
    if (!value.visible || value.status == SlidablePanelStatus.closed) return;
    value = const SlidablePanelValue(
      status: SlidablePanelStatus.closed,
      factor: 0,
    );
    _gesture = false;
  }

  void updateValue(SlidablePanelValue sliderValue) {
    value = value.copyWith(
      factor: sliderValue.factor,
      status: sliderValue.status,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

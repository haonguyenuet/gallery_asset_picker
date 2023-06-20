part of 'slide_sheet.dart';

class SlideSheetController extends ValueNotifier<SlideSheetValue> {
  SlideSheetController({ScrollController? scrollController})
      : _scrollController = scrollController ?? ScrollController(),
        super(SlideSheetValue.closed());

  late _SlideSheetState _state;
  final ScrollController _scrollController;
  bool _gesture = true;

  ScrollController get scrollController => _scrollController;
  SlideSheetStatus get panelStatus => value.status;
  bool get gestureEnabled => _gesture;

  set gestureEnabled(bool isEnable) {
    if (gestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  void _init(_SlideSheetState state) {
    _state = state;
  }

  void open() {
    if (value.status == SlideSheetStatus.collapsed) return;
    value = const SlideSheetValue(
      status: SlideSheetStatus.collapsed,
      factor: 0,
    );
    _gesture = true;
  }

  void collapse() {
    if (!value.visible || value.status == SlideSheetStatus.collapsed) return;
    _state._slideToPosition(0);
  }

  void expand() {
    if (!value.visible || value.status == SlideSheetStatus.expanded) return;
    _state._slideToPosition(1);
  }

  void close() {
    if (!value.visible || value.status == SlideSheetStatus.closed) return;
    value = const SlideSheetValue(
      status: SlideSheetStatus.closed,
      factor: 0,
    );
    _gesture = false;
  }

  void updateValue(SlideSheetValue sliderValue) {
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

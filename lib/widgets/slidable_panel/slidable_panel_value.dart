part of 'slidable_panel.dart';

class SlidablePanelValue {
  const SlidablePanelValue({
    this.factor = 0.0,
    this.status = SlidablePanelStatus.closed,
  });

  /// Sliding state
  final SlidablePanelStatus status;

  /// From 0.0 - 1.0
  final double factor;

  bool get visible => status != SlidablePanelStatus.closed;

  SlidablePanelValue copyWith({
    SlidablePanelStatus? status,
    double? factor,
  }) {
    return SlidablePanelValue(
      status: status ?? this.status,
      factor: factor ?? this.factor,
    );
  }

  factory SlidablePanelValue.closed() {
    return const SlidablePanelValue();
  }
}

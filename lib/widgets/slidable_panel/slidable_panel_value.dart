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

  SlidablePanelValue copyWith({
    SlidablePanelStatus? status,
    double? factor,
  }) {
    return SlidablePanelValue(
      status: status ?? this.status,
      factor: factor ?? this.factor,
    );
  }
}

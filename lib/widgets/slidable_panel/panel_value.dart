part of 'slidable_panel.dart';

class PanelValue {
  const PanelValue({
    this.factor = 0.0,
    this.offset = 0.0,
    this.position = Offset.zero,
    this.status = PanelStatus.close,
  });

  /// Sliding state
  final PanelStatus status;

  /// From 0.0 - 1.0
  final double factor;

  /// Height of the panel
  final double offset;

  /// Position of the panel
  final Offset position;

  ///
  PanelValue copyWith({
    PanelStatus? state,
    double? factor,
    double? offset,
    Offset? position,
  }) {
    return PanelValue(
      status: state ?? this.status,
      factor: factor ?? this.factor,
      offset: offset ?? this.offset,
      position: position ?? this.position,
    );
  }
}

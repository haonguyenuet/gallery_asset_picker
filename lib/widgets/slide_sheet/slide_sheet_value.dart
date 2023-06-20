part of 'slide_sheet.dart';

class SlideSheetValue {
  const SlideSheetValue({
    this.factor = 0.0,
    this.status = SlideSheetStatus.closed,
  });

  /// Sliding state
  final SlideSheetStatus status;

  /// From 0.0 - 1.0
  final double factor;

  bool get visible => status != SlideSheetStatus.closed;

  SlideSheetValue copyWith({
    SlideSheetStatus? status,
    double? factor,
  }) {
    return SlideSheetValue(
      status: status ?? this.status,
      factor: factor ?? this.factor,
    );
  }

  factory SlideSheetValue.closed() {
    return const SlideSheetValue();
  }
}

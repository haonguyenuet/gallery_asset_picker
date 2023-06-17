import 'dart:async';

import 'package:flutter/material.dart';

///
class NavigatorUtils {
  NavigatorUtils._internal(this._context);

  final BuildContext _context;

  NavigatorState get _state => Navigator.of(_context);
  bool get mounted => _state.mounted;

  void pop<T extends Object?>([T? result]) {
    if (!_state.mounted) return;
    _state.pop<T?>(result);
  }

  Future<T?> push<T extends Object?>(Route<T> route) async {
    if (!_state.mounted) return null;
    return _state.push(route);
  }

  factory NavigatorUtils.of(BuildContext context) => NavigatorUtils._internal(context);
}

import 'package:flutter/foundation.dart';

extension ValueNotifierExt<T> on ValueNotifier<T> {
  void setValue(T value) {
    this.value = value;
  }

  T getValue() => value;
}

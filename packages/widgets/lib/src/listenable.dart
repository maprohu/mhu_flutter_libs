import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

extension ValueListenableExt<A> on ValueListenable<A> {
  ValueListenable<B> map<B>({
    required B Function(A input) mapper,
    required AddDisposer? addDisposer,
  }) {
    final result = ValueNotifier(mapper(value));
    final dispose = addValueListener(
      (value) => result.value = mapper(value),
    );
    addDisposer?.call(dispose);
    return result;
  }
}

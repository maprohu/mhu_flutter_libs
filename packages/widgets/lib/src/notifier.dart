import 'package:flutter/cupertino.dart';

ValueNotifier<T> buildValueNotifier<T>(
  T Function(void Function(T value) setValue) builder,
) {
  late final ValueNotifier<T> state;

  state = ValueNotifier(
    builder((value) {
      state.value = value;
    }),
  );

  return state;
}

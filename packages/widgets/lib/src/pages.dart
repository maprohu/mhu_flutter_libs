import 'package:flutter/widgets.dart';
import 'package:mhu_widgets/mhu_widgets.dart';

typedef SetWidget = void Function(Widget widget);

Widget pagesWidget({
  required Widget Function(SetWidget setWidget) builder,
}) {
  return statefulWidget(
    (addDisposer) {
      late final ValueNotifier<Widget> state;

      state = ValueNotifier(
        builder((widget) {
          state.value = widget;
        }),
      );

      return ValueListenableBuilder(
        valueListenable: state,
        builder: (context, value, child) {
          return value;
        },
      );
    },
  );
}

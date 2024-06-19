import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension WidgetIterablePadding on Iterable<Widget> {
  List<Widget> withPadding([
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  ]) {
    return map(
      (widget) => Padding(
        padding: padding,
        child: widget,
      ),
    ).toList();
  }
}

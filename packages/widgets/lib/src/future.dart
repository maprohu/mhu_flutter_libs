import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _log = Logger();

Widget futureWidget(
  Future<Widget> Function() builder, {
  Widget waiting = const Center(child: CircularProgressIndicator()),
}) {
  return FutureBuilder(
    future: builder(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.requireData;
      } else if (snapshot.hasError) {
        _log.e(
          "widget future error",
          error: snapshot.error,
        );
        return ErrorWidget(snapshot.error!);
      } else {
        return waiting;
      }
    },
  );
}

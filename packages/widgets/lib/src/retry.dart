import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

enum AttemptResult {
  repeat,
  exit,
}

({
  AsyncCallback shutdown,
}) asyncRepeat(
  Future<AttemptResult> Function(
    AddAsyncDisposer onCancel,
    bool Function() cancelled,
  ) attempt, {
  Duration delay = const Duration(seconds: 5),
}) {
  bool shouldRepeat = true;

  Future<void> Function() cancel = asyncNoop;

  () async {
    while (shouldRepeat) {
      final onCancel = AsyncDisposers();
      cancel = onCancel.dispose;
      final attemptResult = await attempt(
        onCancel.add,
        () => !shouldRepeat,
      );
      cancel = asyncNoop;

      if (attemptResult == AttemptResult.exit) {
        shouldRepeat = false;
      }

      if (shouldRepeat) {
        await Future.delayed(delay);
      }
    }
  }();

  return (
    shutdown: () async {
      shouldRepeat = false;
      await cancel();
    },
  );
}

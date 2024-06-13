import 'dart:async';
import 'dart:ui';

import 'package:dart_scope_functions/dart_scope_functions.dart';

typedef DirtyRunner = ({
  VoidCallback run,
  Future<void> Function() shutdown,
});

DirtyRunner dirtyRunner(
  Future<void> Function() run, {
  bool start = true,
}) {
  bool running = false;
  bool dirty = false;
  Completer? disposed;

  void ensureRun() async {
    if (running) return;
    running = true;
    try {
      while (dirty) {
        dirty = false;
        await run();
      }
    } finally {
      running = false;

      disposed?.let((it) {
        it.complete(null);
      });
    }
  }

  final runner = () {
    if (disposed != null) return;
    dirty = true;
    ensureRun();
  };

  if (start) {
    runner();
  }

  return (
    run: runner,
    shutdown: () {
      return Completer<void>().also((it) => disposed = it).future;
    },
  );
}

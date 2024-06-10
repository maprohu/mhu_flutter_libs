import 'dart:ui';

VoidCallback dirtyRunner(
  Future<void> Function() run,
) {
  bool running = false;
  bool dirty = false;

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
    }
  }

  return () {
    dirty = true;
    ensureRun();
  };
}

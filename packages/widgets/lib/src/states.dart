import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

({
  AsyncCallback shutdown,
}) boolStateListener({
  required ValueListenable<bool> listenable,
  required Future<AsyncCallback> Function() activate,
}) {
  AsyncCallback? active;
  final control = dirtyRunner(() async {
    final targetActive = listenable.value;

    final currentActive = active;
    if (currentActive != null && !targetActive) {
      await currentActive();
      active = null;
    } else if (currentActive == null && targetActive) {
      active = await activate();
    }
  });

  final removeListener = listenable.addRemovableListener(control.run);

  return (
    shutdown: () async {
      removeListener();
      await control.shutdown();
      await active?.call();
    }
  );
}

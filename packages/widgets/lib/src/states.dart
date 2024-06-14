import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

void startBoolStateListener({
  required ValueListenable<bool> listenable,
  required AddAsyncDisposer? addDisposer,
  required Future<AsyncCallback> Function() activate,
}) {
  startStateListener(
    listenable: listenable,
    activate: (state) async {
      if (state) {
        return await activate();
      } else {
        return asyncNoop;
      }
    },
    addDisposer: addDisposer,
  );

  // AsyncCallback? active;
  // final control = dirtyRunner(() async {
  //   final targetActive = listenable.value;

  //   final currentActive = active;
  //   if (currentActive != null && !targetActive) {
  //     await currentActive();
  //     active = null;
  //   } else if (currentActive == null && targetActive) {
  //     active = await activate();
  //   }
  // });

  // final removeListener = listenable.addRemovableListener(control.run);

  // return (
  //   shutdown: () async {
  //     removeListener();
  //     await control.shutdown();
  //     await active?.call();
  //   }
  // );
}

typedef _Active<S> = ({
  S state,
  AsyncCallback dispose,
});

typedef AsyncActive = ({
  AsyncCallback shutdown,
});

void startStateListener<S>({
  required ValueListenable<S> listenable,
  required AddAsyncDisposer? addDisposer,
  required Future<AsyncCallback> Function(S state) activate,
}) async {
  Future<_Active<S>> doActivate(S state) async => (
        state: state,
        dispose: await activate(state),
      );

  _Active active = await doActivate(listenable.value);

  final control = dirtyRunner(() async {
    final newState = listenable.value;
    if (newState == active.state) return;

    await active.dispose();

    active = await doActivate(newState);
  });

  final removeListener = listenable.addRemovableListener(control.run);

  addDisposer?.call(() async {
    removeListener();
    await control.shutdown();
    await active.dispose();
  });
}

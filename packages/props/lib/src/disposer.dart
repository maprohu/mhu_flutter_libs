import 'package:flutter/foundation.dart';

typedef AddDisposer = void Function(VoidCallback disposer);
typedef AddAsyncDisposer = void Function(AsyncCallback disposer);

class AsyncDisposers {
  final _disposers = <AsyncCallback>[];
  var _disposed = false;

  void addSync(VoidCallback disposer) {
    add(() async => disposer());
  }

  void add(AsyncCallback disposer) {
    if (_disposed) {
      disposer();
      return;
    } else {
      _disposers.add(disposer);
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final diposer in _disposers.reversed) {
      await diposer();
    }
  }
}

Future<void> asyncNoop() async {}

class Disposers {
  final _disposers = <VoidCallback>[];
  var _disposed = false;

  void add(VoidCallback disposer) {
    if (_disposed) {
      disposer();
      return;
    } else {
      _disposers.add(disposer);
    }
  }

  void dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final disposer in _disposers) {
      disposer();
    }
  }
}

({
  T value,
  AsyncCallback dispose,
}) asyncDisposed<T>(T Function(AddAsyncDisposer addDisposer) create) {
  final disposers = AsyncDisposers();
  final result = create(disposers.add);
  return (
    value: result,
    dispose: disposers.dispose,
  );
}

extension AddAsyncDisposerExtension on AddAsyncDisposer {
  AddDisposer toSync() {
    return (VoidCallback disposer) {
      this(() async => disposer());
    };
  }
}
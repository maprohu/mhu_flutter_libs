import 'package:flutter/foundation.dart';

typedef AddDisposer = void Function(VoidCallback disposer);
typedef AddAsyncDisposer = void Function(AsyncCallback disposer);

class AsyncDisposers {
  final _disposers = <AsyncCallback>[];
  var _disposed = false;

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
    await Future.wait(_disposers.map((d) => d()));
  }
}

Future<void> asyncNoop() async {}

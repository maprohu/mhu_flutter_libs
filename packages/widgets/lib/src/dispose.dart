import 'package:flutter/widgets.dart';

mixin DisposableStateMixin<T extends StatefulWidget> on State<T> {
  final _disposers = <VoidCallback>[];

  @override
  void dispose() {
    for (final disposer in _disposers.reversed) {
      disposer();
    }

    super.dispose();
  }

  void addDisposer(VoidCallback disposer) {
    _disposers.add(disposer);
  }

  void triggerSetState() {
    setState(() {});
  }
}

abstract class DisposableState<T extends StatefulWidget> extends State<T>
    with DisposableStateMixin<T> {}

class DisposingWidget extends StatefulWidget {
  final VoidCallback onInit;
  final VoidCallback onDispose;
  final Widget child;
  const DisposingWidget({
    super.key,
    required this.onDispose,
    required this.child,
    required this.onInit,
  });

  @override
  State<DisposingWidget> createState() => _DisposingWidgetState();
}

class _DisposingWidgetState extends State<DisposingWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

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


abstract class DisposableState<T extends StatefulWidget> extends State<T> with DisposableStateMixin<T> {

}
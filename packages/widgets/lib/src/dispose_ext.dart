import 'package:flutter/widgets.dart';
import 'package:mhu_props/mhu_props.dart';
import 'package:protobuf/protobuf.dart';

import 'dispose.dart';

extension DisposableStateExt on DisposableStateMixin {
  void addListenable(Listenable listenable) {
    listenable.addListener(triggerSetState);
    addDisposer(() => listenable.removeListener(triggerSetState));
  }

  ScalarValueHolder<B> addProperty<A extends GeneratedMessage, B>({
    required ReadWriteListenable<A> parent,
    required B Function(A parent) read,
    required void Function(A parent, B value) write,
    bool listen = true,
  }) {
    final newProp = parent.createProperty(
      read: read,
      write: write,
      addDisposer: addDisposer,
    );
    if (listen) {
      addListenable(newProp);
    }

    return newProp;
  }
}

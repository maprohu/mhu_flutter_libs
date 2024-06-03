import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';

import 'props.dart';

extension ReadWritableExt<T> on ReadWritable<T> {
  ReadWritable<S> withConverter<S>(Converter<T, S> converter) {
    return ConvertedReadWritable(readWritable: this, converter: converter);
  }
}

extension ReadWriteListenableExt<A extends GeneratedMessage> on ReadWriteListenable<A> {
  ScalarValueHolder<B> createProperty<B>({
    required B Function(A parent) read,
    required void Function(A parent, B value) write,
    required void Function(VoidCallback disposer)? addDisposer,
  }) {
    final parent = this;
    final newProp = ScalarValueHolder<B>(read(parent.read()));
    newProp.addListener(() {
      parent.write(parent.read().rebuild(
        (o) {
          write(o, newProp.read());
        },
      ));
    });

    void update() {
      newProp.write(
        read(parent.read()),
      );
    }

    newProp.addListener(update);
    addDisposer?.call(
      () {
        newProp.removeListener(update);
      },
    );

    return newProp;
  }
}

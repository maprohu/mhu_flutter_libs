import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';
import 'package:protobuf/protobuf.dart';

import 'props.dart';

extension ReadWritableExt<T> on ReadWritable<T> {
  ReadWritable<S> withConverter<S>(Converter<T, S> converter) {
    return ConvertedReadWritable(readWritable: this, converter: converter);
  }
}

extension ProtoReadWriteListenableExt<A extends GeneratedMessage>
    on ReadWriteListenable<A> {
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

    addListener(update);
    addDisposer?.call(
      () {
        removeListener(update);
      },
    );

    return newProp;
  }
}

extension ReadWriteListenableExt<A> on ReadWriteListenable<A> {
  ScalarValueHolder<B> withWriteConverter<B>(
    Converter<A, B> converter,
  ) {
    final parent = this;
    final newProp = ScalarValueHolder<B>(converter.aToB(parent.read()));
    newProp.addListener(() {
      parent.write(converter.bToA(newProp.read()));
    });

    return newProp;
  }
}

extension BinaryReadWriteListenableExt on ReadWriteListenable<Uint8List> {
  ScalarValueHolder<B> withProtoSerializer<B extends GeneratedMessage>({
    required B emptyMessage,
  }) {
    return withWriteConverter(
      ProtobufBinaryConverter(
        emptyMessage: emptyMessage,
      ),
    );
  }
}

extension ValueListenableExt<V> on ValueListenable<V> {
  VoidCallback fireAndAddValueListener(void Function(V value) listener) {
    listener(value);
    return addValueListener(listener);
  }

  VoidCallback addValueListener(void Function(V value) listener) {
    final trigger = () => listener(value);
    addListener(trigger);
    return () {
      removeListener(trigger);
    };
  }
}

extension ListenableExt on Listenable {
  VoidCallback addRemovableListener(VoidCallback listener) {
    addListener(listener);
    return () {
      removeListener(listener);
    };
  }
}

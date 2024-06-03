import 'package:flutter/foundation.dart';

abstract interface class Readable<T> {
  T read();
}

abstract interface class Writable<T> {
  void write(T value);
}

abstract interface class ReadWritable<T> implements Readable<T>, Writable<T> {}

abstract interface class ReadWriteListenable<T>
    implements ReadWritable<T>, Listenable {}

class ReadWritableImpl<T> implements ReadWritable<T> {
  final T Function() _read;
  final void Function(T value) _write;

  ReadWritableImpl({
    required T Function() read,
    required void Function(T value) write,
  })  : _read = read,
        _write = write;

  @override
  T read() {
    return _read();
  }

  @override
  void write(T value) {
    _write(value);
  }
}

abstract interface class Converter<A, B> {
  A bToA(B b);

  B aToB(A a);
}

class ConvertedReadWritable<A, B> implements ReadWritable<B> {
  final ReadWritable<A> _readWritable;
  final Converter<A, B> _converter;

  ConvertedReadWritable({
    required ReadWritable<A> readWritable,
    required Converter<A, B> converter,
  })  : _readWritable = readWritable,
        _converter = converter;

  @override
  B read() {
    return _converter.aToB(_readWritable.read());
  }

  @override
  void write(B value) {
    return _readWritable.write(_converter.bToA(value));
  }
}

class ScalarValueHolder<T> extends ValueNotifier<T>
    implements ReadWriteListenable<T> {
  ScalarValueHolder(super.value);

  @override
  T read() => value;

  @override
  void write(T value) {
    this.value = value;
  }
}

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

extension ValueListenableExt<A> on ValueListenable<A> {
  ValueListenable<B> map<B>({
    required B Function(A input) mapper,
    required AddDisposer? addDisposer,
  }) {
    final result = ValueNotifier(mapper(value));
    final dispose = addValueListener(
      (value) => result.value = mapper(value),
    );
    addDisposer?.call(dispose);
    return result;
  }

  ValueListenable<C> combine<B, C>({
    required ValueListenable<B> other,
    required C Function(A a, B b) combine,
    required AddDisposer? addDisposer,
  }) {
    final result = ValueNotifier(combine(value, other.value));
    final remove = Listenable.merge([this, other])
        .addRemovableListener(() => result.value = combine(value, other.value));
    addDisposer?.call(remove);
    return result;
  }

  ValueListenable<B> flatMap<B>({
    required ValueListenable<B> Function(A value, AddDisposer addDisposer)
        mapper,
    required AddDisposer? addDisposer,
  }) {
    var itemDisposers = Disposers();
    var mapped = mapper(value, itemDisposers.add);
    final result = ValueNotifier(mapped.value);
    mapped.addValueListener(result.setValue).let(itemDisposers.add);

    final remove = addRemovableListener(() {
      itemDisposers.dispose();
      itemDisposers = Disposers();
      mapped = mapper(value, itemDisposers.add);
      mapped.addValueListener(result.setValue).let(itemDisposers.add);
    });
    addDisposer?.call(() {
      remove();
      itemDisposers.dispose();
    });

    return result;
  }
}

class ChangeNotifierImpl extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  bool get hasListeners => super.hasListeners;
}

ChangeNotifierImpl createChangeNotifer() => ChangeNotifierImpl();

class ValueNotifierImpl<V> extends ValueNotifier<V> {
  ValueNotifierImpl(super.value);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  bool get hasListeners => super.hasListeners;
}

ValueNotifierImpl<V> createValueNotifier<V>(V value) =>
    ValueNotifierImpl(value);

ValueListenable<V> valueListenableOf<V>({
  required void Function(VoidCallback listener) addListener,
  required void Function(VoidCallback listener) removeListener,
  required V Function() value,
}) =>
    ValueListenableImpl(
      addListener: addListener,
      removeListener: removeListener,
      value: value,
    );

class ValueListenableImpl<V> implements ValueListenable<V> {
  final void Function(VoidCallback listener) _addListener;
  final void Function(VoidCallback listener) _removeListener;
  final V Function() _value;

  ValueListenableImpl({
    required void Function(VoidCallback listener) addListener,
    required void Function(VoidCallback listener) removeListener,
    required V Function() value,
  })  : _addListener = addListener,
        _removeListener = removeListener,
        _value = value;

  @override
  void addListener(VoidCallback listener) {
    _addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _removeListener(listener);
  }

  @override
  get value => _value();
}

class ListenableImpl implements Listenable {
  final void Function(VoidCallback listener) _addListener;
  final void Function(VoidCallback listener) _removeListener;

  ListenableImpl({
    required void Function(VoidCallback listener) addListener,
    required void Function(VoidCallback listener) removeListener,
  })  : _addListener = addListener,
        _removeListener = removeListener;
  @override
  void addListener(VoidCallback listener) {
    _addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _removeListener(listener);
  }
}

ValueListenable<T> mergeValueListenable<T>({
  required Iterable<Listenable> sources,
  required T Function() value,
  required AddDisposer? addDisposer,
}) {
  final listenable = Listenable.merge(sources);
  final result = ValueNotifier(value());
  final remove =
      listenable.addRemovableListener(() => result.value = (value()));
  addDisposer?.call(remove);
  return result;
}

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

typedef ListControl<K, V> = ({
  ValueListenable<ListHeadControl<K, V>> headListenable,
  ValueListenable<V> Function(K key) itemListenable,
});

typedef ListHeadControl<K, V> = ({
  int itemCount,
  K Function(int position) getItemAt,
});

typedef ListenableList<K, V extends Object> = ({
  ValueListenable<List<K>> keys,
  ValueListenable<V?> Function(K key) item,
});

typedef ListenableListControl<V> = ({
  void Function(List<V> items) insertOrUpdate,
  void Function(List<V> items) replaceAll,
});

typedef _ItemListenable<V> = ({
  void Function(V value) setValue,
  ValueListenable<V> listenable,
  // void Function(void Function(V value) listener) addListener,
  // void Function(void Function(V value) listener) removeListener,
});

({
  ListenableList<K, V> view,
  ListenableListControl<V> control,
}) createListenableList<K, V extends Object>({
  required K Function(V value) keyFn,
}) {
  final values = <V>[];
  final keyToIndex = <K, int>{};

  final itemListenables = <K, _ItemListenable<V?>>{};

  final keysCache = createCache(
    () => List<K>.unmodifiable(
      values.map(keyFn),
    ),
  );

  final keysChangeNotifier = createChangeNotifer();

  void fireItem(K key, V? value) {
    itemListenables[key]?.let(
      (fn) => fn.setValue(value),
    );
  }

  V? itemForKey(K key) {
    final index = keyToIndex[key];
    return index?.let(values.elementAt);
  }

  return (
    control: (
      insertOrUpdate: (items) {
        bool keysChanged = false;

        for (final item in items) {
          final key = keyFn(item);
          final index = keyToIndex[key];
          if (index == null) {
            keysChanged = true;
            values.add(item);
            keyToIndex[key] = values.length - 1;
          } else {
            values[index] = item;
          }
          fireItem(key, item);
        }
        if (keysChanged) {
          keysCache.invalidate();
          keysChangeNotifier.notifyListeners();
        }
      },
      replaceAll: (items) {
        values.clear();
        values.addAll(items);
        keyToIndex.clear();
        for (final (index, item) in items.indexed) {
          final key = keyFn(item);
          keyToIndex[key] = index;
          fireItem(key, item);
        }
        keysCache.invalidate();
        keysChangeNotifier.notifyListeners();
      },
    ),
    view: (
      keys: valueListenableFromListenable(
        listenable: keysChangeNotifier,
        value: keysCache.get,
      ),
      item: (key) {
        final itemListenable = itemListenables[key];
        if (itemListenable == null) {
          final notifier = ValueNotifierImpl(itemForKey(key));
          final newListenable = valueListenableOf(
            addListener: notifier.addListener,
            removeListener: (listener) {
              notifier.removeListener(listener);
              if (!notifier.hasListeners) {
                itemListenables.remove(key);
              }
            },
            value: notifier.getValue,
          );
          itemListenables[key] = (
            listenable: newListenable,
            setValue: notifier.setValue,
          );
          return newListenable;
        } else {
          return itemListenable.listenable;
        }
      },
    ),
  );
}

ValueListenable<V> valueListenableFromListenable<V>({
  required Listenable listenable,
  required V Function() value,
}) =>
    valueListenableOf(
      addListener: listenable.addListener,
      removeListener: listenable.removeListener,
      value: value,
    );

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

typedef CacheControl<T> = ({
  T Function() get,
  void Function() invalidate,
});

CacheControl<T> createCache<T>(
  T Function() calculate,
) {
  bool hasValue = false;
  late T cachedValue;
  return (
    get: () {
      if (!hasValue) {
        cachedValue = calculate();
      }
      return cachedValue;
    },
    invalidate: () {
      hasValue = false;
    }
  );
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

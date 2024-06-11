import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:mhu_props/mhu_props.dart';

import 'cache.dart';
import 'listenable.dart';

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
  ChangeNotifier changeNotifier,
});

typedef ListenableListControl<V> = ({
  void Function(List<V> items) insertOrUpdate,
  void Function(List<V> items) replaceAll,
});

typedef _ItemListenable<V> = ({
  void Function(V value) trigger,
  ValueNotifierImpl<V> notifier,
  // void Function(void Function(V value) listener) addListener,
  // void Function(void Function(V value) listener) removeListener,
});

typedef ListenableListService<K, V extends Object> = ({
  ListenableList<K, V> view,
  ListenableListControl<V> control,
});

ListenableListService<K, V> createListenableList<K, V extends Object>({
  required K Function(V value) keyFn,
}) {
  final changeNotifer = ChangeNotifierImpl();

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
      (fn) => fn.trigger(value),
    );
  }

  V? itemForKey(K key) {
    final index = keyToIndex[key];
    return index?.let(values.elementAt);
  }

  return (
    control: (
      insertOrUpdate: (items) {
        bool changed = false;
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
          changed = true;
        }
        if (keysChanged) {
          keysCache.invalidate();
          keysChangeNotifier.notifyListeners();
        }
        if (changed) {
          changeNotifer.notifyListeners();
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
      changeNotifier: changeNotifer,
      keys: valueListenableFromListenable(
        listenable: keysChangeNotifier,
        value: keysCache.get,
      ),
      item: (key) {
        return valueListenableOf(
          value: () => itemForKey(key),
          removeListener: (listener) {
            final itemListenable = itemListenables[key]!;
            final notifier = itemListenable.notifier;
            notifier.removeListener(listener);
            if (!notifier.hasListeners) {
              itemListenables.remove(key);
            }
          },
          addListener: (listener) {
            var itemListenable = itemListenables[key];
            if (itemListenable == null) {
              final notifier = ValueNotifierImpl(itemForKey(key));
              itemListenable = (
                notifier: notifier,
                trigger: notifier.setValue,
              );
              itemListenables[key] = itemListenable;
            }
            itemListenable.notifier.addListener(listener);
          },
        );
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

Iterable<V> listenableListValues<K, V extends Object>(
  ListenableList<K, V> list,
) {
  return list.keys.value.map(
    (key) => list.item(key).value!,
  );
}

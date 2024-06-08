import 'package:flutter/foundation.dart';

typedef ListControl<K, V> = ({
  ValueListenable<ListHeadControl<K, V>> headListenable,
  ValueListenable<V> Function(K key) itemListenable,
});

typedef ListHeadControl<K, V> = ({
  int itemCount,
  K Function(int position) getItemAt,

});

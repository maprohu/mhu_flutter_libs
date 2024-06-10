import 'package:flutter/foundation.dart';

export 'cache_none.dart'
    if (dart.library.io) 'cache_io.dart'
    if (dart.library.js) 'cache_web.dart';

typedef BinaryCache = ({
  Future<Uint8List> Function(
    String key,
    Future<Uint8List> Function() fetch,
  ) get,
  Future<void> Function(
    String key,
    Uint8List bytes,
  ) put,
  Future<List<String>> Function() listKeys,
  String path,
  Future<void> Function() clear,
});

typedef BinaryCacheWithStats = ({
  BinaryCache binaryCache,
  ValueListenable<int> count,
});

Future<BinaryCacheWithStats> binaryCacheWithStats({
  required BinaryCache binaryCache,
}) async {
  final keysList = await binaryCache.listKeys();

  final keySet = keysList.toSet();
  final count = ValueNotifier(keySet.length);

  void addKey(String key) {
    keySet.add(key);
    count.value = keySet.length;
  }

  final BinaryCache newCache = (
    get: (key, fetch) async {
      final result = await binaryCache.get(key, fetch);
      addKey(key);
      return result;
    },
    path: binaryCache.path,
    put: (key, bytes) async {
      await binaryCache.put(key, bytes);
      addKey(key);
    },
    listKeys: () async => keySet.toList(),
    clear: () async {
      await binaryCache.clear();
      keySet.clear();
      count.value = 0;
    },
  );

  final BinaryCacheWithStats result = (
    binaryCache: newCache,
    count: count as ValueListenable<int>,
  );

  return result;
}

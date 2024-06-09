
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

  final BinaryCache newCache = (
    get: binaryCache.get,
    path: binaryCache.path,
    put: (key, bytes) async {
      await binaryCache.put(key, bytes);
      keySet.add(key);
      count.value = keySet.length;
    },
    listKeys: () async => keySet.toList(),
  );

  final BinaryCacheWithStats result = (
    binaryCache: newCache,
    count: count as ValueListenable<int>,
  );

  return result;
}

import 'dart:io';
import 'dart:typed_data';

import 'cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<BinaryCache> createBinaryCache(String name) async {
  final supportDir = await getApplicationSupportDirectory();

  final cacheDirPath = p.join(
    supportDir.path,
    "mhu_blob_cache",
    name,
  );

  final cacheDir = Directory(cacheDirPath);
  await cacheDir.create(recursive: true);

  return BinaryCacheIo(directory: cacheDir);
}

class BinaryCacheIo implements BinaryCache {
  final Directory directory;

  BinaryCacheIo({required this.directory});

  @override
  Future<Uint8List> get(String key, Future<Uint8List> Function() fetch) async {
    final file = File(
      p.join(directory.path, key),
    );
    
    if (!await file.exists()) {
      final fetched = await fetch();
      await file.writeAsBytes(fetched);
      return fetched;
    }
    
    return await file.readAsBytes();
  }
}

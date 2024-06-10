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

  final directory = Directory(cacheDirPath);
  await directory.create(recursive: true);

  return (
    get: (
      String key,
      Future<Uint8List> Function() fetch,
    ) async {
      final file = File(
        p.join(directory.path, key),
      );

      if (!await file.exists()) {
        final fetched = await fetch();
        await file.writeAsBytes(fetched);
        return fetched;
      }

      return await file.readAsBytes();
    },
    put: (String key, Uint8List bytes) async {
      final file = File(
        p.join(directory.path, key),
      );
      await file.writeAsBytes(bytes);
    },
    listKeys: () async {
      final entries = await directory.list().toList();
      return [
        for (final entry in entries) p.split(entry.path).last,
      ];
    },
    clear: () async {
      final entries = await directory.list().toList();
      for (final entry in entries) {
        await entry.delete();
      }
    },
    path: directory.absolute.path,
  );
}

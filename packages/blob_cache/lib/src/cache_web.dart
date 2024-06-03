import 'dart:typed_data';

import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_client.dart';

import 'cache.dart';

import 'package:idb_shim/idb_browser.dart';

const _keyProp = "key";
const _dataProp = "data";

Future<BinaryCache> createBinaryCache(String name) async {
  final factory = idbFactoryBrowser;
  final database = await factory.open(
    name,
    version: 1,
    onUpgradeNeeded: (event) {
      event.database.createObjectStore(name, keyPath: _keyProp);
    },
  );

  return BinaryCacheIdb(name: name, database: database);
}


class BinaryCacheIdb implements BinaryCache {
  final String name;
  final Database database;

  BinaryCacheIdb({required this.name, required this.database});

  Future<T> readonly<T>(Future<T> Function(ObjectStore store) action,) =>
      txn(false, action);

  Future<T> readwrite<T>(Future<T> Function(ObjectStore store) action,) =>
      txn(true, action);

  Future<T> txn<T>(bool write,
      Future<T> Function(ObjectStore store) action,) async {
    final mode = write ? "readwrite" : "readonly";
    final tx = database.transaction(name, mode);
    final store = tx.objectStore(name);

    try {
      return await action(store);
    } finally {
      await tx.completed;
    }
  }

  @override
  Future<Uint8List> get(String key, Future<Uint8List> Function() fetch) async {
    final existing = await readonly((store) async {
      final record = await store.getObject(key) as Map?;

      if (record == null) {
        return null;
      }

      return record[_dataProp] as Uint8List?;
    });

    if (existing != null) {
      return existing;
    }

    final fetched = await fetch();

    await readwrite((store) async {
      await store.put({
        _keyProp: key,
        _dataProp: fetched,
      });
    });
    
    return fetched;
  }
}

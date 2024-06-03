import 'dart:typed_data';

export 'cache_none.dart'
    if (dart.library.io) 'cache_io.dart'
    if (dart.library.js) 'cache_web.dart';
    
abstract interface class BinaryCache {
    Future<Uint8List> get(String key, Future<Uint8List> Function() fetch);
}


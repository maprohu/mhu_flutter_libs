import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:fixnum/fixnum.dart';

Int64 Function() hiveSequenceProp({
  required Box box,
  required String key,
}) {
  return () {
    final List<int>? bytes = box.get(key);
    Int64 value;
    if (bytes == null) {
      value = Int64.ZERO;
    } else {
      value = Int64.fromBytes(bytes);
    }

    final nextValue = value + 1;

    box.put(
      key,
      nextValue.toBytes(),
    );

    return value;
  };
}

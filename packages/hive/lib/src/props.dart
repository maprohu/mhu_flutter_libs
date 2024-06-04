import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:mhu_props/mhu_props.dart';
import 'package:protobuf/protobuf.dart';

ReadWriteListenable<H> hiveProp<H>({
  required Box box,
  required dynamic key,
  required H defaultValue,
}) {
  final holder = ScalarValueHolder<H>(
    box.get(
      key,
      defaultValue: defaultValue,
    ),
  );

  holder.addListener(
    () {
      box.put(key, holder.value);
    },
  );

  return holder;
}

ReadWriteListenable<Uint8List> hiveBinaryProp({
  required Box box,
  required dynamic key,
}) =>
    hiveProp(
      box: box,
      key: key,
      defaultValue: Uint8List(0),
    );

ReadWriteListenable<M> hiveProtobufProp<M extends GeneratedMessage>({
  required Box box,
  required dynamic key,
  required M emptyMessage,
}) =>
    hiveBinaryProp(
      box: box,
      key: key,
    ).withProtoSerializer(
      emptyMessage: emptyMessage,
    );



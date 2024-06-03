import 'package:hive/hive.dart';
import 'package:mhu_props/mhu_props.dart';

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

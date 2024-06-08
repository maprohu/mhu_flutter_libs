import 'package:freezed_annotation/freezed_annotation.dart';
export 'package:freezed_annotation/freezed_annotation.dart';

const freezedState = Freezed(
  equal: false,
  map: FreezedMapOptions.none,
  when: FreezedWhenOptions.none,
);
const freezedEnum = Freezed(
  map: FreezedMapOptions.none,
  when: FreezedWhenOptions.none,
);

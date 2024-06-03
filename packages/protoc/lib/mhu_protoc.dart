import 'dart:io';

Future<void> runProtoc({
  required String inDir,
  required String outDir,
}) async {
  print("runProtoc: ${Directory(inDir).absolute}");
  await Directory(outDir).create(recursive: true);
  final process = await Process.start(
    "protoc",
    [
      "--dart_out=$outDir",
      "--proto_path=$inDir",
      "$inDir/*",
    ],
    mode: ProcessStartMode.inheritStdio,
  );
  await process.exitCode;
}
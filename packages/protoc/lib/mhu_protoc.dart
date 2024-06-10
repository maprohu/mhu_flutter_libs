import 'dart:io';
// import 'package:path/path.dart' as p;

Future<void> runProtoc({
  required String inDir,
  required String outDir,
}) async {
  // inDir = p.absolute(inDir);
  // outDir = p.absolute(outDir);
  print("runProtoc: $inDir");
  await Directory(outDir).create(recursive: true);

  final process = await Process.start(
    "protoc",
    [
      "--dart_out=$outDir",
      "--proto_path=$inDir",
      // "$inDir/",
      ...Directory(inDir)
          .listSync()
          .whereType<File>()
          .map((e) => e.path),
    ],
    mode: ProcessStartMode.inheritStdio,
  );
  await process.exitCode;
}

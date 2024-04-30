import 'dart:io';

class Workspace {
  final Directory directory =
      Directory.systemTemp.createTempSync('codegen_benchmark');

  void write(String path, {required String source}) {
    final file = File('${directory.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  void pubGet() {
    write('pubspec.yaml', source: '''
name: benchmark_large_library_cycle
publish_to: none

environment:
  sdk: '>=3.5.0-0 <4.0.0'

dependencies:
dev_dependencies:
dependency_overrides:
''');
    final result = Process.runSync('dart', ['pub', 'get'],
        workingDirectory: directory.path);
    if (result.exitCode != 0) throw result.stderr;
  }
}

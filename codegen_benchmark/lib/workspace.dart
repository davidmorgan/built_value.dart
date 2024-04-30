import 'dart:io';

class Workspace {
  final Directory directory =
      Directory(Directory.systemTemp.path + '/codegen_benchmark');
  //Directory.systemTemp.createTempSync('codegen_benchmark');

  String get packagePath => '${directory.path}/package_under_test';
  String get packageUri => '${directory.uri}/package_under_test';

  Workspace() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
    directory.createSync();
  }

  void write(String path, {required String source}) {
    final file = File('$packagePath/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  void pubGet() {
    write('pubspec.yaml', source: '''
name: package_under_test
publish_to: none

environment:
  sdk: '>=3.5.0-0 <4.0.0'

dependencies:
  macros: ^0.1.0-main
dev_dependencies:
dependency_overrides:
  analyzer:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/analyzer
  macros:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/macros
  _fe_analyzer_shared:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/_fe_analyzer_shared

''');
    final result =
        Process.runSync('dart', ['pub', 'get'], workingDirectory: packagePath);
    if (result.exitCode != 0) throw result.stderr;
  }
}

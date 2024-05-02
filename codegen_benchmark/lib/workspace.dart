import 'dart:io';

class Workspace {
  final Directory directory =
      Directory(Directory.systemTemp.path + '/codegen_benchmark');
  //Directory.systemTemp.createTempSync('codegen_benchmark');
  final List<String> _addedPackages = [];

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

  void delete(String path) {
    File('$packagePath/$path').deleteSync();
  }

  void addPackage({required String name, required String from}) {
    _addedPackages.add(name);
    final result = Process.runSync('cp', ['-a', from, '${directory.path}']);
    if (result.exitCode != 0) throw '${result.stdout} ${result.stderr}';
  }

  Future<void> pubGet() async {
    final moreDependencies = StringBuffer();
    final moreDependencyOverrides = StringBuffer();
    for (final package in _addedPackages) {
      moreDependencies.writeln('  $package: any');
      moreDependencyOverrides.writeln('  $package:');
      moreDependencyOverrides.writeln('    path: ../$package');
    }

    write('pubspec.yaml', source: '''
name: package_under_test
publish_to: none

environment:
  sdk: '>=3.5.0-0 <4.0.0'

dependencies:
  macros: ^0.1.0-main
$moreDependencies

dev_dependencies:
  build_runner: any

dependency_overrides:
  analyzer:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/analyzer
  _macros:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/_macros
  macros:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/macros
  _fe_analyzer_shared:
    path: /usr/local/google/home/davidmorgan/git/dart-sdk/sdk/pkg/_fe_analyzer_shared
$moreDependencyOverrides

''');
    final result = await Process.run('dart', ['pub', 'get'],
        workingDirectory: packagePath);
    if (result.exitCode != 0) throw result.stderr;
  }
}

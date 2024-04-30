import 'dart:math';

import 'package:codegen_benchmark/codegen_benchmark_runner.dart';

Future<void> main() async {
  final runner = CodegenBenchmarkRunner();
  await runner.run();

  for (var i = 0; i != 1000; ++i) {
    runner.workspace.write('lib/foo$i.dart', source: createClass(i));
  }

  for (var i = 0; i != 30; ++i) {
    runner.workspace.write('lib/foo0.dart',
        source: createClass(0, withError: true, withCacheBuster: true));
    print(await runner.analysisServer
        .timeWaitForMessageMs(hasDiagnosticMessage('unused_import')));

    runner.workspace.write('lib/foo0.dart',
        source: createClass(0, withError: false, withCacheBuster: true));
    print(await runner.analysisServer
        .timeWaitForMessageMs(hasNoDiagnosticMessages()));
  }
}

String createClass(int i,
    {bool withError = false, bool withCacheBuster = false}) {
  final nextI = (i + 1) % 1000;
  final blob = StringBuffer();
  for (var i = 0; i != 1000; ++i) {
    blob.write('int? foo$i;');
  }
  return '''
${withError ? 'import "dart:io";' : ''}
import 'foo${nextI}.dart';
class Foo$i {
  Foo${nextI}? next;
  ${blob}
}
${withCacheBuster ? cacheBuster : ''}
''';
}

bool Function(Object) hasDiagnosticMessage(String code) => (message) =>
    message is Map &&
    message['method'] == 'textDocument/publishDiagnostics' &&
    message['params']!['diagnostics'].any((i) => i['code'] == 'unused_import');

bool Function(Object) hasNoDiagnosticMessages() => (message) =>
    message is Map &&
    message['method'] == 'textDocument/publishDiagnostics' &&
    message['params']!['diagnostics'].isEmpty;

final random = Random();
String get cacheBuster => 'class CacheBuster${random.nextInt(1000000000)} {}';

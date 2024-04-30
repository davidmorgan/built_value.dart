import 'dart:math';

import 'package:codegen_benchmark/codegen_benchmark_runner.dart';

Future<void> main() async {
  final runner = CodegenBenchmarkRunner();
  await runner.run();

  runner.workspace.write('lib/to_string_macro.dart', source: '''
// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:macros/macros.dart';

macro class ToStringMacro implements ClassDeclarationsMacro {
  const ToStringMacro();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final stringIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'String');
    final stringBufferIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'StringBuffer');
    final fields = await builder.fieldsOf(clazz);
    builder.declareInType(DeclarationCode.fromParts([
      stringIdentifier,
      ' toString() {',
      'return (',
      stringBufferIdentifier,
      '()',
      for (final field in fields) ...[
        '..write("',
        field.identifier.name,
        r': \${',
        field.identifier,
        '?.toString()}")',
      ],
      ').toString();',
      '}',
     ]));
  }
}
''');

  print('withMacro,#files in library cycle,samples in ms...');
  for (var max = 1; max < 1000; max *= 2) {
    for (var withMacro in [false, true]) {
      for (var i = 0; i != max; ++i) {
        runner.workspace.write('lib/foo$i.dart',
            source: createClass(i, max, withMacro: withMacro));
      }

      var future = runner.analysisServer
          .timeWaitForMessageMs(hasDiagnosticMessage('unused_import'));
      runner.workspace.write('lib/foo0.dart',
          source: createClass(0, max,
              withError: true, withCacheBuster: true, withMacro: withMacro));
      await future;

      future =
          runner.analysisServer.timeWaitForMessageMs(hasNoDiagnosticMessages());
      runner.workspace.write('lib/foo0.dart',
          source: createClass(0, max,
              withError: false, withCacheBuster: true, withMacro: withMacro));
      await future;

      final results = [];
      for (var i = 0; i != 15; ++i) {
        future = runner.analysisServer
            .timeWaitForMessageMs(hasDiagnosticMessage('unused_import'));
        runner.workspace.write('lib/foo0.dart',
            source: createClass(0, max,
                withError: true, withCacheBuster: true, withMacro: withMacro));
        results.add(await future);

        future = runner.analysisServer
            .timeWaitForMessageMs(hasNoDiagnosticMessages());
        runner.workspace.write('lib/foo0.dart',
            source: createClass(0, max,
                withError: false, withCacheBuster: true, withMacro: withMacro));
        results.add(await future);
      }
      print('$withMacro,$max,${results.join(',')}');
    }
  }
}

String createClass(int i, int max,
    {bool withError = false,
    bool withCacheBuster = false,
    bool withMacro = false}) {
  final nextI = (i + 1) % max;
  final blob = StringBuffer();
  for (var i = 0; i != 1000; ++i) {
    blob.write('int? foo$i;\n');
  }
  return '''
${withError ? 'import "dart:io";' : ''}
${i != nextI ? "import 'foo${nextI}.dart';" : ''}
${withMacro ? "import 'to_string_macro.dart';" : ''}
${withMacro ? '@ToStringMacro()' : ''}
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

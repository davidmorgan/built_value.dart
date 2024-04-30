import 'package:codegen_benchmark/codegen_benchmark_runner.dart';

Future<void> main() async {
  final runner = CodegenBenchmarkRunner();
  await runner.run();

  runner.workspace
      .write('lib/foo.dart', source: 'import "dart:io"; class Foo {}');
  print(await runner.analysisServer.timeWaitForMessageMs((message) {
    return message is Map &&
        message['method'] == 'texDocument/publishDiagnostics' &&
        message['params']!['diagnostics']
            .any((i) => i['code'] == 'unused_import');
  }));
}

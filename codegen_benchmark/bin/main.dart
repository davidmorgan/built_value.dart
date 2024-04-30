import 'package:codegen_benchmark/codegen_benchmark_runner.dart';

Future<void> main() async {
    final runner = CodegenBenchmarkRunner();
    runner.workspace.write('lib/foo.dart', source: 'class Foo {}');
    await runner.run();
}

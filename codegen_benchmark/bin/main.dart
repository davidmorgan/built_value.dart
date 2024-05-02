import 'dart:math';

import 'package:codegen_benchmark/codegen_benchmark_runner.dart';
import 'package:codegen_benchmark/trivial_macros/input_generator.dart';
import 'package:codegen_benchmark/workspace.dart';

Future<void> main() async {
  /*print('numberOfMacros,librariesPerCycle,changeRelevantInput/ms');
  for (final librariesPerCycle in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]) {
    for (final numberOfMacros in [0, 1, 2, 3]) {
      final strategies = Strategies.withNumberOfMacros(numberOfMacros);

      final inputGenerator = TrivialMacrosInputGenerator(
          fieldsPerClass: 100,
          classesPerLibrary: 10,
          librariesPerCycle: librariesPerCycle,
          strategies: strategies);
      final runner = CodegenBenchmarkRunner();
      await runner.run();

      var future = runner.analysisServer.timeAnalysis();
      inputGenerator.generate(runner.workspace);
      await future;

      final results = <int>[];
      for (var i = 0; i != 3; ++i) {
        future = runner.analysisServer.timeAnalysis();
        inputGenerator.changeRevelantInput(runner.workspace);
        results.add(await future);
      }
      print([numberOfMacros, librariesPerCycle, ...results].join(', '));

      runner.close();
    }
  }*/

  print('strategy,librariesPerCycle,changeRelevantInput/ms');
  for (final librariesPerCycle in [16, 32, 64]) {
    for (final strategy in [
      Strategy.manual,
      Strategy.macro,
      Strategy.codegen,
    ]) {
      final strategies = Strategies(
          equalsStrategy: strategy,
          hashCodeStrategy: strategy,
          toStringStrategy: strategy);

      final inputGenerator = TrivialMacrosInputGenerator(
          fieldsPerClass: 100,
          classesPerLibrary: 10,
          librariesPerCycle: librariesPerCycle,
          strategies: strategies);
      final workspace = Workspace();
      inputGenerator.generate(workspace);
      await workspace.pubGet();
      final runner = CodegenBenchmarkRunner(workspace);
      await runner.run();
      if (strategies.anyCodegenStrategy) {
        await runner.buildRunner.start(runner.workspace);
        await runner.buildRunner.timeSuccess();
      }

      await runner.analysisServer.waitForAnalysis();
      while (runner.analysisServer.diagnostics.isNotEmpty) {
        await runner.analysisServer.waitForAnalysis();
      }

      final results = <int>[];
      for (var i = 0; i != 4; ++i) {
        final stopwatch = Stopwatch()..start();
        inputGenerator.changeRevelantInput(runner.workspace);
        if (strategies.anyCodegenStrategy) {
          await runner.buildRunner.timeSuccess();
        }
        await runner.analysisServer.waitForAnalysis();
        results.add(stopwatch.elapsedMilliseconds);
      }
      print([strategy, librariesPerCycle, ...results.skip(1)].join(', '));

      runner.close();
    }
  }
}

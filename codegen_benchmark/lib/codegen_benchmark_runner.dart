import 'package:codegen_benchmark/analysis_server.dart';
import 'package:macros/macros.dart';

import 'analysis_server.dart';
import 'build_runner.dart';
import 'incremental_runner.dart';
import 'workspace.dart';

class CodegenBenchmarkRunner {
  final Workspace workspace;
  late final AnalysisServer analysisServer =
      AnalysisServer(workspace: workspace);
  final BuildRunner buildRunner = BuildRunner();
  final IncrementalRunner incrementalRunner = IncrementalRunner();

  CodegenBenchmarkRunner(this.workspace);

  Future<void> run() async {
    await analysisServer.start();
  }

  Future<void> close() async {
    await analysisServer.close();
    await buildRunner.close();
    await incrementalRunner.close();
  }
}

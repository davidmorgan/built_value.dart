import 'package:codegen_benchmark/analysis_server.dart';

import 'workspace.dart';

class CodegenBenchmarkRunner {
  final Workspace workspace = Workspace();
  final AnalysisServer analysisServer = AnalysisServer();

  Future<void> run() async {
    workspace.pubGet();
    await analysisServer.start(workspace);
  }
}

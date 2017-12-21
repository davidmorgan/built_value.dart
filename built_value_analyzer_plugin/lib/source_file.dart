import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

class SourceFile {
  final NextAction nextAction;
  final String path;
  final AnalysisResult analysisResult;
  final List<AnalysisError> analysisErrors;
  final Map<AnalysisError, AnalysisErrorFixes> analysisErrorFixes;

  SourceFile(this.nextAction, this.path, this.analysisResult,
      this.analysisErrors, this.analysisErrorFixes);

  SourceFile withAnalysisResult(AnalysisResult analysisResult) =>
      new SourceFile(this.nextAction, this.path, analysisResult,
          this.analysisErrors, this.analysisErrorFixes);
}

enum NextAction {
  analyze,
  check,
  publish,
}

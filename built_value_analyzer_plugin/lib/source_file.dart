import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

class SourceFile {
  final NextAction nextAction;
  final String path;
  final AnalysisResult analysisResult;
  final List<AnalysisError> analysisErrors;
  final Map<AnalysisError, AnalysisErrorFixes> analysisErrorFixes;

  SourceFile(this.nextAction, this.path, this.analysisResult,
      this.analysisErrors, this.analysisErrorFixes) {
    log(this.toString());
  }

  SourceFile withNextAction(NextAction nextAction) => new SourceFile(nextAction,
      this.path, analysisResult, this.analysisErrors, this.analysisErrorFixes);

  SourceFile withAnalysisResult(AnalysisResult analysisResult) =>
      new SourceFile(NextAction.check, this.path, analysisResult,
          this.analysisErrors, this.analysisErrorFixes);

  SourceFile doCheck() {
    if (nextAction != NextAction.check)
      throw new StateError(nextAction.toString());

    final errors = <AnalysisError>[];

    for (final compilationUnit in analysisResult.libraryElement.units) {
      for (final type in compilationUnit.types) {
        for (final interface in type.interfaces) {
          final expectedInterface =
              'Built<${type.displayName}, ${type.displayName}Builder>';

          if (interface.displayName.startsWith('Built<') &&
              interface.displayName != expectedInterface) {
            final node = type.computeNode();
            final lineInfo = compilationUnit.lineInfo;
            final offsetLineLocation = lineInfo.getLocation(node.offset);
            final error = new AnalysisError(
                AnalysisErrorSeverity.INFO,
                AnalysisErrorType.HINT,
                new Location(
                    path,
                    node.offset,
                    node.length,
                    offsetLineLocation.lineNumber,
                    offsetLineLocation.columnNumber),
                'Wrong implements.',
                'whee',
                correction: 'correctMe',
                hasFix: true);
            errors.add(error);

            final fix = new AnalysisErrorFixes(error, fixes: [
              new PrioritizedSourceChange(
                  0,
                  new SourceChange(
                    'fix fix fix',
                    edits: [
                      new SourceFileEdit(
                        path,
                        0,
                        edits: [
                          new SourceEdit(
                            node.offset,
                            node.length,
                            'foo bar baz',
                          )
                        ],
                      )
                    ],
                  ))
            ]);
            analysisErrorFixes[error] = fix;
          }
        }
      }
    }

    return new SourceFile(NextAction.publish, this.path, this.analysisResult,
        errors, this.analysisErrorFixes);
  }

  @override
  String toString() {
    return '$path: $nextAction';
  }
}

enum NextAction {
  analyze,
  wait,
  check,
  publish,
  done,
}

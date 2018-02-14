import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

class Checker {
  Map<AnalysisError, PrioritizedSourceChange> check(
      AnalysisResult analysisResult) {
    final result = <AnalysisError, PrioritizedSourceChange>{};
    if (analysisResult.unit == null) {
      log('no unit!');
      return result;
    }

    for (final compilationUnit in analysisResult?.libraryElement?.units ??
        <CompilationUnitElement>[]) {
      for (final type in compilationUnit.types) {
        log('check ${type.displayName}');
        if (!type.interfaces.any((i) => i.displayName.startsWith('Built')))
          continue;
        log('check ${type.displayName} via ast');
        final visitor = new BuiltParametersVisitor();
        type.computeNode().accept(visitor);
        if (visitor.result != null) {
          final name = type.displayName;
          final expectedParams = '$name, ${name}Builder';
          if (visitor.result == expectedParams) continue;

          final lineInfo = compilationUnit.lineInfo;
          final offsetLineLocation = lineInfo.getLocation(visitor.offset);
          final error = new AnalysisError(
              AnalysisErrorSeverity.INFO,
              AnalysisErrorType.HINT,
              new Location(
                  analysisResult.path,
                  visitor.offset,
                  visitor.length,
                  offsetLineLocation.lineNumber,
                  offsetLineLocation.columnNumber),
              'Class must implement Built<$expectedParams> to use built_value.',
              '',
              correction: 'correctMe',
              hasFix: true);

          final fix = new PrioritizedSourceChange(
              0,
              new SourceChange(
                'Implement Built<$expectedParams> for built_value.',
                edits: [
                  new SourceFileEdit(
                    analysisResult.path,
                    0,
                    edits: [
                      new SourceEdit(
                        visitor.offset,
                        visitor.length,
                        'implements Built<$expectedParams>',
                      )
                    ],
                  )
                ],
              ));
          result[error] = fix;
        }
      }
    }

    return result;
  }
}

/// Extracts the type parameters used for the `Built` interface.
class BuiltParametersVisitor extends RecursiveAstVisitor {
  String result;
  int offset;
  int length;

  @override
  void visitImplementsClause(ImplementsClause implementsClause) {
    for (final interface in implementsClause.interfaces) {
      final parameters =
          _extractParameters('Built', 'Built<', interface.toString());

      if (parameters != null) {
        result = parameters;
        offset = implementsClause.offset;
        length = implementsClause.length;
      }
    }
  }

  /// If [[code]] starts with [[prefix]] then strips it off, strips off the
  /// last character, and returns it.
  ///
  /// Otherwise returns null.
  String _extractParameters(String match, String prefix, String code) {
    if (code == match) {
      return '';
    } else if (code.startsWith(prefix)) {
      return code.substring(prefix.length, code.length - 1);
    } else {
      return null;
    }
  }
}

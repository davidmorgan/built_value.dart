import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

class Checker {
  Map<AnalysisError, PrioritizedSourceChange> check(
      LibraryElement libraryElement) {
    final result = <AnalysisError, PrioritizedSourceChange>{};

    for (final compilationUnit in libraryElement.units) {
      for (final type in compilationUnit.types) {
        if (!type.interfaces.any((i) => i.displayName.startsWith('Built')))
          continue;

        final visitor = new BuiltParametersVisitor();
        // NodeLocator2 gives us the AST node for a particular offset--don't need
        // computeNode.
        type.computeNode().accept(visitor);
        if (visitor.result != null) {
          final name = type.displayName;
          final typeParameters = type.typeParameters.join(', ');
          final typeParametersWithBrackets =
              typeParameters.isEmpty ? '' : '<$typeParameters>';
          final expectedParams = '$name$typeParametersWithBrackets, '
              '${name}Builder$typeParametersWithBrackets';
          if (visitor.result == expectedParams) continue;

          final lineInfo = compilationUnit.lineInfo;
          final offsetLineLocation = lineInfo.getLocation(visitor.offset);
          final error = new AnalysisError(
              AnalysisErrorSeverity.ERROR,
              AnalysisErrorType.COMPILE_TIME_ERROR,
              new Location(
                  compilationUnit.source.fullName,
                  visitor.offset,
                  visitor.length,
                  offsetLineLocation.lineNumber,
                  offsetLineLocation.columnNumber),
              'Class must implement Built<$expectedParams> to use built_value.',
              '',
              correction: 'correctMe',
              hasFix: true);

          // Take a look at utilities/change_builder for examples.
          final fix = new PrioritizedSourceChange(
              100,
              new SourceChange(
                'Implement Built<$expectedParams> for built_value.',
                edits: [
                  new SourceFileEdit(
                    compilationUnit.source.fullName,
                    compilationUnit.source.modificationStamp,
                    edits: [
                      new SourceEdit(
                        visitor.offset,
                        visitor.length,
                        'Built<$expectedParams>',
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
        offset = interface.offset;
        length = interface.length;
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

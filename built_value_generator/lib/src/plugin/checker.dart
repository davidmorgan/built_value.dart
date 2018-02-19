import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_generator/src/value_source_class.dart';
//import 'package:built_value_generator/src/value_source_class.dart';

class Checker {
  Map<AnalysisError, PrioritizedSourceChange> check(
      LibraryElement libraryElement) {
    final result = <AnalysisError, PrioritizedSourceChange>{};

    for (final compilationUnit in libraryElement.units) {
      for (final type in compilationUnit.types) {
        if (!type.interfaces.any((i) => i.displayName.startsWith('Built')))
          continue;

        // Need to only check if not in *.g.dart.
        // Then: better errors class than string. Easy...
        final ValueSourceClass sourceClass = new ValueSourceClass(type);
        final errors = sourceClass.computeErrors();

        if (errors.isNotEmpty) {
          final lineInfo = compilationUnit.lineInfo;

          final offset = errors.first.position;
          final length = errors.first.length;

          final offsetLineLocation = lineInfo.getLocation(offset);
          final error = new AnalysisError(
              AnalysisErrorSeverity.ERROR,
              AnalysisErrorType.COMPILE_TIME_ERROR,
              new Location(
                  compilationUnit.source.fullName,
                  offset,
                  length,
                  offsetLineLocation.lineNumber,
                  offsetLineLocation.columnNumber),
              'Class has Built errors: ' + errors.join('\n'),
              '',
              correction: 'correctMe',
              hasFix: true);

          // Take a look at utilities/change_builder for examples.
          final fix = new PrioritizedSourceChange(
              100,
              new SourceChange(
                'Fix Built errors.',
                edits: [
                  new SourceFileEdit(
                    compilationUnit.source.fullName,
                    compilationUnit.source.modificationStamp,
                    edits: errors
                        .where((error) => error.fix != null)
                        .map((error) => new SourceEdit(
                            error.position, error.length, error.fix))
                        .toList(),
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

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_generator/src/value_source_class.dart';

class Checker {
  Map<AnalysisError, PrioritizedSourceChange> check(
      LibraryElement libraryElement) {
    final result = <AnalysisError, PrioritizedSourceChange>{};

    for (final compilationUnit in libraryElement.units) {
      // Don't analyze generated source; there's nothing to do.
      if (compilationUnit.source.fullName.endsWith('.g.dart')) continue;

      for (final type in compilationUnit.types) {
        if (!type.interfaces.any((i) => i.displayName.startsWith('Built')))
          continue;

        final ValueSourceClass sourceClass = new ValueSourceClass(type);
        final errors = sourceClass.computeErrors();

        if (errors.isNotEmpty) {
          final lineInfo = compilationUnit.lineInfo;

          // Report one error on the 'Built' interface. Bundle together all the
          // necessary fixes.

          // TODO: split error message and example; only show example in the
          // build error.
          //
          // TODO: stop overusing computeNode.
          final builtNode = sourceClass.classDeclaration.implementsClause.interfaces
              .singleWhere((typeName) => typeName.name.name == 'Built');
          final offset = builtNode.offset;
          final length = builtNode.length;
          final offsetLineLocation = lineInfo.getLocation(offset);
          final error = new AnalysisError(
              AnalysisErrorSeverity.ERROR,
              AnalysisErrorType.LINT,
              new Location(
                  compilationUnit.source.fullName,
                  offset,
                  length,
                  offsetLineLocation.lineNumber,
                  offsetLineLocation.columnNumber),
              'Class needs fixes for built_value: ' +
                  errors.map((error) => error.message).join(' '),
              'BUILT_VALUE_NEEDS_FIXES');

          // Take a look at utilities/change_builder for examples.

          final edits = errors
              .where((error) => error.fix != null)
              .map((error) =>
                  new SourceEdit(error.offset, error.length, error.fix))
              .toList();
          edits.sort((left, right) => right.offset.compareTo(left.offset));

          final fix = new PrioritizedSourceChange(
              1000000,
              new SourceChange(
                'Apply fixes for built_value.',
                edits: [
                  new SourceFileEdit(
                    compilationUnit.source.fullName,
                    compilationUnit.source.modificationStamp,
                    edits: edits,
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

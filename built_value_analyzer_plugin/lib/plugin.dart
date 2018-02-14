import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/context/context_root.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:built_value_analyzer_plugin/logger.dart';

class BuiltValueAnalyzerPlugin extends ServerPlugin {
  final Map<plugin.AnalysisError, plugin.PrioritizedSourceChange>
      analysisErrorFixes =
      <plugin.AnalysisError, plugin.PrioritizedSourceChange>{};

  BuiltValueAnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    log('Create driver');

    final root = new ContextRoot(contextRoot.root, contextRoot.exclude)
      ..optionsFilePath = contextRoot.optionsFile;
    final contextBuilder =
        new ContextBuilder(resourceProvider, sdkManager, null)
          ..analysisDriverScheduler = analysisDriverScheduler
          ..byteStore = byteStore
          ..performanceLog = performanceLog
          ..fileContentOverlay = fileContentOverlay;
    final result = contextBuilder.buildDriver(root);
    result.results.listen(processResult);
    return result;
  }

  @override
  List<String> get fileGlobsToAnalyze {
    return const ['*.dart'];
  }

  @override
  String get name {
    return 'Built Value Analysis Plugin';
  }

  @override
  String get version {
    return '1.0.0-alpha.0';
  }

  @override
  String get contactInfo => 'hi';

  @override
  void onError(Object exception, StackTrace stackTrace) {}

  void processResult(AnalysisResult result) {
    log('processResult ${result.path}');

    final errors = <plugin.AnalysisError>[];
    if (result.unit == null) {
      log('no unit!');
      return;
    }
    try {
      for (final compilationUnit
          in result?.libraryElement?.units ?? <CompilationUnitElement>[]) {
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
            final error = new plugin.AnalysisError(
                plugin.AnalysisErrorSeverity.INFO,
                plugin.AnalysisErrorType.HINT,
                new plugin.Location(
                    result.path,
                    visitor.offset,
                    visitor.length,
                    offsetLineLocation.lineNumber,
                    offsetLineLocation.columnNumber),
                'Class must implement Built<$expectedParams> to use built_value.',
                '',
                correction: 'correctMe',
                hasFix: true);
            errors.add(error);

            final fix = new plugin.PrioritizedSourceChange(
                0,
                new plugin.SourceChange(
                  'Implement Built<$expectedParams> for built_value.',
                  edits: [
                    new plugin.SourceFileEdit(
                      result.path,
                      0,
                      edits: [
                        new plugin.SourceEdit(
                          visitor.offset,
                          visitor.length,
                          'implements Built<$expectedParams>',
                        )
                      ],
                    )
                  ],
                ));
            analysisErrorFixes[error] = fix;
          }
        }
      }
      channel.sendNotification(
          new plugin.AnalysisErrorsParams(result.path, errors)
              .toNotification());
    } catch (e, stack) {
      log(e.toString() + '\n' + stack.toString());
    }
  }

  @override
  void contentChanged(String path) {
    super.driverForPath(path).addFile(path);
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
      plugin.EditGetFixesParams parameters) async {
    final fixes = <plugin.AnalysisErrorFixes>[];

    for (final error in analysisErrorFixes.keys) {
      if (error.location.file == parameters.file) {
        fixes.add(new plugin.AnalysisErrorFixes(error,
            fixes: [analysisErrorFixes[error]]));
      }
    }

    return new plugin.EditGetFixesResult(fixes);
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
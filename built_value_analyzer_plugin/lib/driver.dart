import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/source_file.dart';

class BuiltValueDriver implements AnalysisDriverGeneric {
  final AnalysisDriver driver;
  final AnalysisDriverScheduler scheduler;
  final PluginCommunicationChannel channel;

  final Map<String, SourceFile> _sourceFiles = new Map<String, SourceFile>();

  BuiltValueDriver(this.driver, this.scheduler, this.channel) {
    scheduler.add(this);
  }

  @override
  void addFile(String path) {
    _sourceFiles[path] = new SourceFile(NextAction.analyze, path, null, [], {});
  }

  @override
  void dispose() {}

  @override
  bool get hasFilesToAnalyze =>
      _sourceFiles.values.any((f) => f.nextAction == NextAction.analyze);

  @override
  Future<Null> performWork() {
    for (final sourceFile in _sourceFiles.values
        .where((f) => f.nextAction == NextAction.analyze)) {
      driver.getResult(sourceFile.path).then((result) {
        _sourceFiles[sourceFile.path] = sourceFile.withAnalysisResult(result);
        scheduler.notify(this);
      });
    }

    for (final path in _resultsToProcess) {
      final result = _analysisResults[path];

      for (final compilationUnit in result.libraryElement.units) {
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
              _errors[path] = error;
              _errorsToPublish.add(path);
            }
          }
        }
      }
    }
    _resultsToProcess.clear();

    for (final path in _errorsToPublish) {
      final error = _errors[path];
      channel.sendNotification(
          new AnalysisErrorsParams(path, [error]).toNotification());
    }
    _errorsToPublish.clear();

    return new Future.value(null);
  }

  @override
  set priorityFiles(List<String> priorityPaths) {}

  @override
  AnalysisDriverPriority get workPriority {
    return _pathsToAnalyze.isEmpty
        ? AnalysisDriverPriority.nothing
        : AnalysisDriverPriority.interactive;
  }

  Future<EditGetFixesResult> getFixes(EditGetFixesParams parameters) async {
    if (_errors.isEmpty) {
      return new EditGetFixesResult([]);
    }

    return new EditGetFixesResult([
      new AnalysisErrorFixes(_errors.values.first,
          fixes: <PrioritizedSourceChange>[
            new PrioritizedSourceChange(
                0,
                new SourceChange('fix fix fix', edits: [
                  new SourceFileEdit(
                      '/usr/local/google/home/davidmorgan/git/built-value-dart/built_value/lib/built_value.dart',
                      0,
                      edits: [
                        new SourceEdit(
                          0,
                          10,
                          'wheeeee',
                        )
                      ])
                ])),
          ])
    ]);
  }
}

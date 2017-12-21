import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

int count = 0;

class BuiltValueDriver implements AnalysisDriverGeneric {
  final AnalysisDriver driver;
  final AnalysisDriverScheduler scheduler;
  final PluginCommunicationChannel channel;

  final Set<String> _pathsToAnalyze = new Set<String>();
  final Map<String, AnalysisResult> _analysisResults =
      new Map<String, AnalysisResult>();
  final Set<String> _resultsToProcess = new Set<String>();
  final Map<String, AnalysisError> _errors = new Map<String, AnalysisError>();
  final Set<String> _errorsToPublish = new Set<String>();

  BuiltValueDriver(this.driver, this.scheduler, this.channel) {
    scheduler.add(this);
  }

  @override
  void addFile(String path) {
    _pathsToAnalyze.add(path);
    scheduler.notify(this);
  }

  @override
  void dispose() {}

  @override
  bool get hasFilesToAnalyze => _pathsToAnalyze.isNotEmpty;

  @override
  Future<Null> performWork() {
    for (final path in _pathsToAnalyze) {
      driver.getResult(path).then((result) {
        _analysisResults[path] = result;
        _resultsToProcess.add(path);
        scheduler.notify(this);
      });
    }
    _pathsToAnalyze.clear();

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

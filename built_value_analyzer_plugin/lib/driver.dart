import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';
import 'package:built_value_analyzer_plugin/source_file.dart';

Set<String> pending = new Set<String>();
int count = 0;

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
    log('addFile');
    _sourceFiles[path] = new SourceFile(NextAction.analyze, path, null, [], {});
    scheduler.notify(this);
  }

  @override
  void dispose() {}

  @override
  bool get hasFilesToAnalyze {
    log('hasFilesToAnalyze ${_sourceFiles.values.any((f) => f.nextAction == NextAction.analyze)}');
    return _sourceFiles.values.any((f) => f.nextAction == NextAction.analyze);
  }

  @override
  Future<Null> performWork() {
    ++count;
    final myCount = count;
    log('performWork $myCount');
    try {
      for (final sourceFile in _sourceFiles.values
          .where((f) => f.nextAction == NextAction.analyze)) {
        if (sourceFile.path.endsWith('.dart')) {
          _sourceFiles[sourceFile.path] =
              sourceFile.withNextAction(NextAction.wait);

          pending.add(sourceFile.path);
          log('++${pending.length}: $pending');
          driver.getResult(sourceFile.path).then((result) {
            pending.remove(sourceFile.path);
            log('--${pending.length}: $pending');

            _sourceFiles[sourceFile.path] =
                sourceFile.withAnalysisResult(result);
            scheduler.notify(this);
          }, onError: (e, stack) => log(stack.toString()));
        } else {
          _sourceFiles[sourceFile.path] =
              sourceFile.withNextAction(NextAction.done);
        }

        return new Future.value(null);
      }

      for (final sourceFile in _sourceFiles.values
          .where((f) => f.nextAction == NextAction.check)) {
        _sourceFiles[sourceFile.path] = sourceFile.doCheck();
        return new Future.value(null);
      }

      for (final sourceFile in _sourceFiles.values
          .where((f) => f.nextAction == NextAction.publish)) {
        channel.sendNotification(
            new AnalysisErrorsParams(sourceFile.path, sourceFile.analysisErrors)
                .toNotification());
        _sourceFiles[sourceFile.path] =
            sourceFile.withNextAction(NextAction.done);
        return new Future.value(null);
      }

      return new Future.value(null);
    } finally {
      log('end performWork $myCount');
    }
  }

  @override
  set priorityFiles(List<String> priorityPaths) {}

  @override
  AnalysisDriverPriority get workPriority {
    log('workPriority');
    return hasFilesToAnalyze
        ? AnalysisDriverPriority.general
        : AnalysisDriverPriority.nothing;
  }

  Future<EditGetFixesResult> getFixes(EditGetFixesParams parameters) async {
    log('getFixes');
    final fixes = <AnalysisErrorFixes>[];
    _sourceFiles.values
        .forEach((f) => fixes.addAll(f.analysisErrorFixes.values));
    return new EditGetFixesResult(fixes);
  }
}

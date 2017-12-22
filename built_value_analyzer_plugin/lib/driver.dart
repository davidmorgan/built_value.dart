import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';
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
    log('addFile');
    _sourceFiles[path] = new SourceFile(NextAction.analyze, path, null, [], {});
    scheduler.notify(this);
  }

  @override
  void dispose() {}

  @override
  bool get hasFilesToAnalyze => _nextSourceFile() != null;

  SourceFile _nextSourceFile() => _sourceFiles.values.firstWhere(
      (f) => f.nextAction != NextAction.wait && f.nextAction != NextAction.done,
      orElse: () => null);

  @override
  Future<Null> performWork() {
    final sourceFile = _nextSourceFile();
    log('PerformWork: $sourceFile');
    if (sourceFile != null) {
      _sourceFiles[sourceFile.path] = _performWork(sourceFile);
    }
    log('-->${_sourceFiles[sourceFile.path]}');

    return new Future.value(null);
  }

  SourceFile _performWork(SourceFile sourceFile) {
    switch (sourceFile.nextAction) {
      case NextAction.analyze:
        if (sourceFile.path.endsWith('.dart')) {
          driver.getResult(sourceFile.path).then((result) {
            _sourceFiles[sourceFile.path] =
                sourceFile.withAnalysisResult(result);
            scheduler.notify(this);
          }, onError: (e, stack) => log(stack.toString()));

          return sourceFile.withNextAction(NextAction.wait);
        }
        return sourceFile.withNextAction(NextAction.done);

      case NextAction.check:
        return sourceFile.doCheck();

      case NextAction.publish:
        channel.sendNotification(
            new AnalysisErrorsParams(sourceFile.path, sourceFile.analysisErrors)
                .toNotification());

        return sourceFile.withNextAction(NextAction.done);

      default:
        throw new StateError(sourceFile.nextAction.toString());
    }
  }

  @override
  set priorityFiles(List<String> priorityPaths) {}

  @override
  AnalysisDriverPriority get workPriority {
    //log('workPriority');
    return hasFilesToAnalyze
        ? AnalysisDriverPriority.general
        : AnalysisDriverPriority.nothing;
  }

  Future<EditGetFixesResult> getFixes(EditGetFixesParams parameters) async {
    //log('getFixes');
    final fixes = <AnalysisErrorFixes>[];
    _sourceFiles.values
        .forEach((f) => fixes.addAll(f.analysisErrorFixes.values));
    return new EditGetFixesResult(fixes);
  }
}

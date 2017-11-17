import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

class BuiltValueDriver implements AnalysisDriverGeneric {
  final PluginCommunicationChannel channel;

  Set<String> files = new Set<String>();

  BuiltValueDriver(this.channel);

  @override
  void addFile(String path) {
    log('addFile $path');
    files.add(path);
  }

  @override
  void dispose() {
    log('dispose');
    // TODO: implement dispose
  }

  // TODO: implement hasFilesToAnalyze
  @override
  bool get hasFilesToAnalyze {
    log('hasFilesToAnalyze');
    return files.isNotEmpty;
  }

  @override
  Future<Null> performWork() async {
    log('performWork');
    channel.sendNotification(new AnalysisErrorsParams(files.first, [
      new AnalysisError(
          AnalysisErrorSeverity.ERROR,
          AnalysisErrorType.SYNTACTIC_ERROR,
          new Location(files.first, 0, 10, 2, 3),
          'foo bar baz',
          'whee')
    ]).toNotification());
    files.clear();
  }

  @override
  set priorityFiles(List<String> priorityPaths) {
    log('priorityFiles');
  }

  // TODO: implement workPriority
  @override
  AnalysisDriverPriority get workPriority {
    log('workPriority');
    return AnalysisDriverPriority.interactive;
  }
}

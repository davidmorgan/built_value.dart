import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

class BuiltValueDriver implements AnalysisDriverGeneric {
  final PluginCommunicationChannel channel;

  Set<String> files = new Set<String>();

  BuiltValueDriver(this.channel);

  @override
  void addFile(String path) {
    files.add(path);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  // TODO: implement hasFilesToAnalyze
  @override
  bool get hasFilesToAnalyze => files.isNotEmpty;

  @override
  Future<Null> performWork() async {
    channel.sendNotification(new AnalysisErrorsParams(files.first, [
      new AnalysisError(AnalysisErrorSeverity.ERROR, AnalysisErrorType.LINT,
          new Location(files.first, 0, 10, 2, 3), 'foo bar baz', 'whee')
    ]).toNotification());
    files.clear();
  }

  @override
  set priorityFiles(List<String> priorityPaths) {}

  // TODO: implement workPriority
  @override
  AnalysisDriverPriority get workPriority => AnalysisDriverPriority.interactive;
}

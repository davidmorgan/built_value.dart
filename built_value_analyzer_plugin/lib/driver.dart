import 'dart:async';

import 'package:analyzer/src/dart/analysis/driver.dart';

class BuiltValueDriver implements AnalysisDriverGeneric {
  @override
  void addFile(String path) {
    // TODO: implement addFile
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  // TODO: implement hasFilesToAnalyze
  @override
  bool get hasFilesToAnalyze => null;

  @override
  Future<Null> performWork() {
    return null;
  }

  @override
  set priorityFiles(List<String> priorityPaths) {
    // TODO: implement priorityFiles
  }

  // TODO: implement workPriority
  @override
  AnalysisDriverPriority get workPriority => null;
}

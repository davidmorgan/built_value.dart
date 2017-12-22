import 'dart:async';

import 'package:analyzer/context/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:built_value_analyzer_plugin/driver.dart';

class BuiltValueAnalyzerPlugin extends ServerPlugin {
  BuiltValueAnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    final root = new ContextRoot(contextRoot.root, contextRoot.exclude)
      ..optionsFilePath = contextRoot.optionsFile;
    final contextBuilder =
        new ContextBuilder(resourceProvider, sdkManager, null)
          ..analysisDriverScheduler = analysisDriverScheduler
          ..byteStore = byteStore
          ..performanceLog = performanceLog
          ..fileContentOverlay = fileContentOverlay;
    return new BuiltValueDriver(
        contextBuilder.buildDriver(root), analysisDriverScheduler, channel);
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

  @override
  void contentChanged(String path) {
    super.driverForPath(path).addFile(path);
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
      plugin.EditGetFixesParams parameters) async {
    return await (driverForPath(parameters.file) as BuiltValueDriver)
        .getFixes(parameters);
  }
}

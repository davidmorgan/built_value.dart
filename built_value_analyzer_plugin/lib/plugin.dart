import 'dart:async';

import 'package:analyzer/context/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:built_value_analyzer_plugin/checker.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

class BuiltValueAnalyzerPlugin extends ServerPlugin {
  final Checker checker = new Checker();

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
    final result = contextBuilder.buildDriver(root);
    result.results.listen(processResult);
    return result;
  }

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'Built Value Analysis Plugin';

  @override
  String get version => '1.0.0-alpha.0';

  @override
  String get contactInfo => 'https://github.com/google/built_value.dart/issues';

  void processResult(AnalysisResult analysisResult) {
    try {
      final checkResult = checker.check(analysisResult);
      channel.sendNotification(new plugin.AnalysisErrorsParams(
              analysisResult.path, checkResult.keys.toList())
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

    final checkResult = checker.check(
        (driverForPath(parameters.file) as AnalysisDriver)
            .getCachedResult(parameters.file));

    for (final error in checkResult.keys) {
      if (error.location.file == parameters.file) {
        fixes.add(new plugin.AnalysisErrorFixes(error,
            fixes: [checkResult[error]]));
      }
    }

    return new plugin.EditGetFixesResult(fixes);
  }
}

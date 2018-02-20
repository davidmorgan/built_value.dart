import 'dart:async';

import 'package:analyzer/context/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:built_value_generator/src/plugin/checker.dart';
import 'package:built_value_generator/src/plugin/logger.dart';

// ignore_for_file: implementation_imports
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
      if (analysisResult.unit == null ||
          analysisResult.libraryElement == null) {
        channel.sendNotification(
            new plugin.AnalysisErrorsParams(analysisResult.path, [])
                .toNotification());
        return;
      }
      final checkResult = checker.check(analysisResult.libraryElement);
      channel.sendNotification(new plugin.AnalysisErrorsParams(
              analysisResult.path, checkResult.keys.toList())
          .toNotification());
    } catch (e, stackTrace) {
      // Send notification.
      channel.sendNotification(new plugin.PluginErrorParams(
              false, e.toString(), stackTrace.toString())
          .toNotification());
    }
  }

  @override
  void contentChanged(String path) {
    super.driverForPath(path).addFile(path);
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
      plugin.EditGetFixesParams parameters) async {
    try {
      final analysisResult =
          await (driverForPath(parameters.file) as AnalysisDriver)
              .getResult(parameters.file);

      if (analysisResult == null) {
        return new plugin.EditGetFixesResult([]);
      }

      if (analysisResult.unit == null ||
          analysisResult.libraryElement == null) {
        return new plugin.EditGetFixesResult([]);
      }

      final checkResult = checker.check(analysisResult?.libraryElement);

      final fixes = <plugin.AnalysisErrorFixes>[];
      for (final error in checkResult.keys) {
        if (error.location.file == parameters.file &&
            checkResult[error].change.edits.single.edits.isNotEmpty) {
          fixes.add(new plugin.AnalysisErrorFixes(error,
              fixes: [checkResult[error]]));
        }
      }

      return new plugin.EditGetFixesResult(fixes);
    } catch (e, stackTrace) {
      // Send notification.
      channel.sendNotification(new plugin.PluginErrorParams(
              false, e.toString(), stackTrace.toString())
          .toNotification());
      return new plugin.EditGetFixesResult([]);
    }
  }
}

import 'dart:async';

import 'package:analyzer/context/context_root.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/plugin/fix_mixin.dart';
import 'package:built_value_analyzer_plugin/logger.dart';

class BuiltValueAnalyzerPlugin extends ServerPlugin with FixesMixin {
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
    return contextBuilder.buildDriver(root);
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
  List<FixContributor> getFixContributors(String path) => [new MyFixContributor()];

  @override
  Future<FixesRequest> getFixesRequest(plugin.EditGetFixesParams parameters) async {

    // Use UriResolver or ResourceUriResolver to get a Source
    return new FixesRequestImpl([
  new AnalysisError(parameters., 1, 1, new MyErrorCode('foo', 'bar')),

    ], parameters.offset, resourceProvider);
  }
}

class FixesRequestImpl implements FixesRequest {
  @override
  final List<AnalysisError> errorsToFix;

  @override
  final int offset;

  @override
  final ResourceProvider resourceProvider;

  FixesRequestImpl(this.errorsToFix, this.offset, this.resourceProvider);
}

class MyErrorCode extends ErrorCode {
  MyErrorCode(String name, String message) : super(name, message);

  @override
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;

  @override
  ErrorType get type => ErrorType.COMPILE_TIME_ERROR;
}

class MyFixContributor extends FixContributor {
  @override
  void computeFixes(FixesRequest request, FixCollector collector) {
    log('computeFixes: $request');
  }
}
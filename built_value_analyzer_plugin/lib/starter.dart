import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:built_value_analyzer_plugin/logger.dart';
import 'package:built_value_analyzer_plugin/plugin.dart';

void start(List<String> args, SendPort sendPort) {
  log('starting');

  new ServerPluginStarter(
          new BuiltValueAnalyzerPlugin(PhysicalResourceProvider.INSTANCE))
      .start(sendPort);

  log('started/done');
}

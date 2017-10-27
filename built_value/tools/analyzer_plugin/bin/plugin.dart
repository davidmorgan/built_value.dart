import 'dart:io';
import 'dart:isolate';

import 'package:built_value_analyzer_plugin/starter.dart';

void main(List<String> args, SendPort sendPort) {
  new File('/tmp/itlives').writeAsStringSync('Hi hi');

  start(args, sendPort);
}

import 'package:built_value_ng/built_value_ng.dart';
import 'package:ng_host/ng_host.dart';

Future<void> main(List<String> arguments) async {
  await NgHost(
    macros: [BuiltValueNg()],
    sdkSummaryPath: arguments[0],
    workspace: arguments[1],
  ).run();
}

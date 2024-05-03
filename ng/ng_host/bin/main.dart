import 'package:ng_generators/equals_generator_ng.dart';
import 'package:ng_generators/hash_code_generator_ng.dart';
import 'package:ng_generators/to_string_generator_ng.dart';
import 'package:ng_host/ng_host.dart';

Future<void> main(List<String> arguments) async {
  await NgHost(
    macros: [EqualsGeneratorNg(), HashCodeGeneratorNg(), ToStringGeneratorNg()],
    workspace: arguments[0],
    output: true,
  ).run();
}

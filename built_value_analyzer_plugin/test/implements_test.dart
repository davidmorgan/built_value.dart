import 'package:build_test/build_test.dart';
import 'package:built_value_analyzer_plugin/checker.dart';
import 'package:test/test.dart';

void main() {
  final checker = new Checker();

  group('corrects implements statement', () {
    test('with no generics', () async {
      final element = await resolveSource(
                  'library test_library; class Built {}; class Foo implements Built {}',
                  (resolver) => resolver.findLibraryByName('test_library'));

      final results = checker.check(element);
      throw results;
    });
  });
}

import 'package:build_test/build_test.dart';
import 'package:built_value_analyzer_plugin/checker.dart';
import 'package:test/test.dart';

void main() {
  final checker = new Checker();

  group('corrects implements statement', () {
    test('with no generics', () async {
      final src = 'class Foo implements Built {}';
      final srcPrefix = 'library test_library; class Built {};';
      final totalSrc = '$srcPrefix$src';

      final element = await resolveSource(
          totalSrc, (resolver) => resolver.findLibraryByName('test_library'));

      final results = checker.check(element);

      var fixedSrc = totalSrc;
      for (final correction in results.values) {
        for (final edits in correction.change.edits) {
          for (final edit in edits.edits) {
            fixedSrc = fixedSrc.replaceRange(
                edit.offset, edit.offset + edit.length, edit.replacement);
          }
        }
      }

      expect(fixedSrc, startsWith(srcPrefix));
      fixedSrc = fixedSrc.substring(srcPrefix.length);

      expect(fixedSrc, 'class Foo implements Built<Foo, FooBuilder> {}');
    });
  });
}

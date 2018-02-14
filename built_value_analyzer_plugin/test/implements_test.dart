import 'package:build_test/build_test.dart';
import 'package:built_value_analyzer_plugin/checker.dart';
import 'package:test/test.dart';

import 'tester.dart';

void main() {
  group('corrects implements statement', () {
    test('with no generics', () async {
      await expectCorrection('class Foo implements Built {}',
          'class Foo implements Built<Foo, FooBuilder> {}');
    });

    test('with wrong generics', () async {
      await expectCorrection('class Foo implements Built<Bar, Baz> {}',
          'class Foo implements Built<Foo, FooBuilder> {}');
    });
  });
}

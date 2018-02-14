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

    test('with interfaces and extends', () async {
      await expectCorrection(
          'class Foo extends Bar implements Bar, Built<Bar, Baz>, Bop {}',
          'class Foo extends Bar '
          'implements Bar, Built<Foo, FooBuilder>, Bop {}');
    });

    test('with generic class', () async {
      await expectCorrection('class Foo<T> implements Built {}',
          'class Foo<T> implements Built<Foo<T>, FooBuilder<T>> {}');
    });
  });
}

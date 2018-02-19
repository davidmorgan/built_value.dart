import 'package:test/test.dart';

import 'plugin_tester.dart';

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

    test('with interfaces and no generics', () async {
      await expectCorrection(
          'class Foo extends Bar implements Bar, Built, Bop {}',
          'class Foo extends Bar '
              'implements Bar, Built<Foo, FooBuilder>, Bop {}');
    });

    test('with generic class', () async {
      await expectCorrection('class Foo<T> implements Built {}',
          'class Foo<T> implements Built<Foo<T>, FooBuilder<T>> {}');
    });

    test('with awkward formatting', () async {
      await expectCorrection(
          '''class Foo extends Bar implements Bar<A,
    B>, Built,
    Bop {}''',
          '''class Foo extends Bar implements Bar<A,
    B>, Built<Foo, FooBuilder>,
    Bop {}''');
    });
  });
}

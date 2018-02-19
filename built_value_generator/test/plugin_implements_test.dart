// Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'plugin_tester.dart';

void main() {
  group('corrects implements statement', () {
    test('with no generics', () async {
      await expectCorrection('class Foo implements Built {Foo._();}',
          'class Foo implements Built<Foo, FooBuilder> {Foo._();}');
    });

    test('with wrong generics', () async {
      await expectCorrection('class Foo implements Built<Bar, Baz> {Foo._();}',
          'class Foo implements Built<Foo, FooBuilder> {Foo._();}');
    });

    test('with interfaces and extends', () async {
      await expectCorrection(
          'class Foo extends Bar implements Bar, Built<Bar, Baz>, Bop {Foo._();}',
          'class Foo extends Bar '
          'implements Bar, Built<Foo, FooBuilder>, Bop {Foo._();}');
    });

    test('with interfaces and no generics', () async {
      await expectCorrection(
          'class Foo extends Bar implements Bar, Built, Bop {Foo._();}',
          'class Foo extends Bar '
          'implements Bar, Built<Foo, FooBuilder>, Bop {Foo._();}');
    });

    test('with generic class', () async {
      await expectCorrection('class Foo<T> implements Built {Foo._();}',
          'class Foo<T> implements Built<Foo<T>, FooBuilder<T>> {Foo._();}');
    });

    test('with awkward formatting', () async {
      await expectCorrection(
          '''class Foo extends Bar implements Bar<A,
    B>, Built,
    Bop {Foo._();}''',
          'class Foo extends Bar implements Bar<A, B>, '
          'Built<Foo, FooBuilder>, Bop {Foo._();}');
    });
  });

  group('does not touch correct implements statement', () {
    test('with awkward formatting', () async {
      await expectNoCorrection(
          '''class Foo extends Bar implements Bar<A,
    B>, Built<Foo, FooBuilder>,
    Bop {Foo._();}''');
    });
  });
}
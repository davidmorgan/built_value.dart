// Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'plugin_tester.dart';

void main() {
  group('corrects constructors', () {
    test('when there is one invalid constructor', () async {
      await expectCorrection(
          '''part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {
  factory Foo() => new _\$Foo();
  Foo();
}''', '''part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {
  factory Foo() => new _\$Foo();
  Foo._();
}''');
    });

    test('when the are no constructors', () async {
      await expectCorrection(
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();}',
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();Foo._();}');
    });

    test('when the are multiple invalid constructors', () async {
      await expectCorrection(
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();Foo.a();Foo.b();}',
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();Foo._();}');
    });

    test('when the are valid and invalid constructors', () async {
      await expectCorrection(
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();Foo._() {}Foo.b();}',
          'part \'_resolve_source.g.dart\';abstract class Foo implements Built<Foo, FooBuilder> {factory Foo() => new _\$Foo();Foo._() {}}');
    });
  });
}

import 'package:test/test.dart';
import 'package:value/value.dart';
import 'package:value/values.dart';

void main() {
  group('SimpleValue', () {
    test('can be instantiated', () {
      SimpleValue((b) => b..anInt = 0);
    });

    test('throws on null for non-nullable fields on build', () {
      expect(() => SimpleValue((_) {}), throwsA(const TypeMatcher<Error>()));
    });

    test('includes field name in null error message', () {
      expect(() => SimpleValue((_) {}), throwsA(isErrorContaining('anInt')));
    });

    test('includes class name in null error message', () {
      expect(
          () => SimpleValue((_) {}), throwsA(isErrorContaining('SimpleValue')));
    });

    test('fields can be set via build constructor', () {
      final value = SimpleValue((b) => b
        ..anInt = 1
        ..aString = 'two'
        ..$mustBeEscaped = true);
      expect(value.anInt, 1);
      expect(value.aString, 'two');
      expect(value.$mustBeEscaped, true);
    });

    test('fields can be updated via rebuild method', () {
      final value = SimpleValue((b) => b
        ..anInt = 0
        ..aString = ''
        ..$mustBeEscaped = true).rebuild((b) => b
        ..anInt = 1
        ..aString = 'two'
        ..$mustBeEscaped = false);
      expect(value.anInt, 1);
      expect(value.aString, 'two');
      expect(value.$mustBeEscaped, false);
    });

    test('builder can be instantiated', () {
      SimpleValueBuilder();
    });

    test('builder exposes values via getters', () {
      final builder = SimpleValue((b) => b
        ..anInt = 0
        ..aString = '').toBuilder();
      expect(builder.anInt, 0);
    });

    test('compares equal when equal', () {
      final value1 = SimpleValue((b) => b
        ..anInt = 0
        ..aString = '');
      final value2 = SimpleValue((b) => b
        ..anInt = 0
        ..aString = '');
      expect(value1, value2);
    });

    test('compares not equal when not equal', () {
      final value1 = SimpleValue((b) => b
        ..anInt = 0
        ..aString = '');
      final value2 = SimpleValue((b) => b
        ..anInt = 1
        ..aString = '');
      expect(value1, isNot(equals(value2)));
    });
  });

  group('CompoundValue', () {
    test('can be instantiated', () {
      CompoundValue((b) => b..simpleValue.anInt = 1);
    });
  });
}

Matcher isErrorContaining(String string) => _ErrorContaining(string);

class _ErrorContaining extends TypeMatcher<Error> {
  String string;

  _ErrorContaining(this.string);

  @override
  Description describe(Description description) {
    super.describe(description);
    description.add(' containing "$string"');
    return description;
  }

  @override
  bool matches(dynamic item, Map<Object?, Object?> matchState) =>
      item is Error && item.toString().contains(string);
}

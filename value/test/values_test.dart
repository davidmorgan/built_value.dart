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

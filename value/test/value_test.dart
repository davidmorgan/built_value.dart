import 'package:test/test.dart';
import 'package:value/value.dart';

void main() {
  test('instantiation', () {
    final value = SimpleValue((b) => b..anInt = 3);
    print(value);
    print(value.rebuild((b) => b..anInt = 4));

    final v2 = CompoundValue((b) => b..simpleValue.anInt = 4);
    print(v2);
  });
}

@Value()
class SimpleValue {
  final int anInt;

  String toString() => 'SimpleValue(anInt: $anInt)';
}

@Value()
class CompoundValue {
  final SimpleValue simpleValue;

  String toString() => 'CompoundValue(simpleValue: $simpleValue)';
}

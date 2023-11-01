import 'package:value/value.dart';

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

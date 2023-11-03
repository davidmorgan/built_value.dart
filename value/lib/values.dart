import 'package:value/value.dart';

@Value()
class SimpleValue implements HasBuilder {
  final int anInt;

  final String? aString;
  final bool? $mustBeEscaped;

  String toString() => 'SimpleValue(anInt: $anInt)';
}

@ValueBuilder()
class SimpleValueBuilder {}

@Value()
class CompoundValue {
  final SimpleValue simpleValue;

  String toString() => 'CompoundValue(simpleValue: $simpleValue)';
}

@ValueBuilder()
class CompoundValueBuilder {}

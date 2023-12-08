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

@Value()
class ValidatedValue {
  final int anInt;
  final String? aString;

  @Validate
  void validate() {
    if (anInt == 7) throw StateError('anInt may not be 7');
  }
}

@ValueBuilder()
class ValidatedValueBuilder {}

/*@SerializersFor([
  Value,
])*/
// Initializer should be added by the macro...
final Serializers serializers = Serializers();

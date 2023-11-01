import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro class Value implements ClassDeclarationsMacro, ClassTypesMacro {
  const Value();

  @override
  FutureOr<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz, MemberDeclarationBuilder builder) {
    if (clazz.identifier.name == 'SimpleValue') {
    builder.declareInType(DeclarationCode.fromString('''
factory SimpleValue(void Function(SimpleValueBuilder) updates) {
  final builder = SimpleValueBuilder();
  updates(builder);
  return builder.build();
}

SimpleValue._({required this.anInt});

SimpleValueBuilder toBuilder() => SimpleValueBuilder()..anInt = anInt;

SimpleValue rebuild(void Function(SimpleValueBuilder) updates) {
  final builder = toBuilder();
  updates(builder);
  return builder.build();
}
'''));
    } else if (clazz.identifier.name == 'CompoundValue') {
builder.declareInType(DeclarationCode.fromString('''
factory CompoundValue(void Function(CompoundValueBuilder) updates) {
  final builder = CompoundValueBuilder();
  updates(builder);
  return builder.build();
}

CompoundValue._({required this.simpleValue});

CompoundValueBuilder toBuilder() => CompoundValueBuilder()..simpleValue = simpleValue.toBuilder();

CompoundValue rebuild(void Function(CompoundValueBuilder) updates) {
  final builder = toBuilder();
  updates(builder);
  return builder.build();
}
'''));
    } else {
      throw 'unsupported';
    }
  }

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) {
    if (clazz.identifier.name == 'SimpleValue') {
    builder.declareType('SimpleValueBuilder', DeclarationCode.fromString(
      '''
import 'package:value/value.dart';

class SimpleValueBuilder {
  int? anInt;

  SimpleValue build() {
    ValueNullFieldError.checkNotNull(anInt, 'SimpleValue', 'anInt');
    return SimpleValue._(anInt: anInt!);
  }
}
'''
    ));
    } else if (clazz.identifier.name == 'CompoundValue') {
builder.declareType('CompoundValueBuilder', DeclarationCode.fromString(
      '''
class CompoundValueBuilder {
  SimpleValueBuilder simpleValue = SimpleValueBuilder();

  CompoundValue build() => CompoundValue._(simpleValue: simpleValue.build());
}
'''
    ));
    } else {
      throw 'unsupported';
    }
  }
}

/// [Error] indicating that a `value` class constructor was called with
/// a `null` value for a field not marked nullable.
class ValueNullFieldError extends Error {
  final String type;
  final String field;

  ValueNullFieldError(this.type, this.field);

  /// Throws a [BuiltValueNullFieldError] if [value] is `null`.
  static T checkNotNull<T>(T? value, String type, String field) {
    if (value == null) {
      throw ValueNullFieldError(type, field);
    }
    return value;
  }

  @override
  String toString() =>
      'Tried to construct class "$type" with null for non-nullable field "$field".';
}

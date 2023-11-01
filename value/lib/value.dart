import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro class Value implements ClassDeclarationsMacro, ClassTypesMacro {
  const Value();

  @override
  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz, MemberDeclarationBuilder builder) async {
      final parts = <Object>[];

      final builderType = '${clazz.identifier.name}Builder';
      parts.addAll([
        'factory ',
        clazz.identifier.name,
        '(void Function($builderType) updates) {',
        'final builder = $builderType();',
        'updates(builder);',
        'return builder.build();'
        '}'
      ]);

      parts.addAll([
        clazz.identifier.name,
        '._({'
      ]);

      for (final field in await builder.fieldsOf(clazz)) {
        parts.add('required this.${field.identifier.name},');
      }
      parts.add('});');

      parts.addAll([
        builderType,
        ' toBuilder() => $builderType();',
      ]);

      parts.addAll([
        clazz.identifier.name,
        ' rebuild(void Function($builderType) updates) {',
  'final builder = toBuilder();',
  'updates(builder);',
  'return builder.build();',
'}'

      ]);

      builder.declareInType(DeclarationCode.fromParts(parts));
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

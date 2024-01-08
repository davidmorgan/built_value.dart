import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

import 'serializers_for_impl.dart';
import 'value_builder_impl.dart';
import 'value_impl.dart';

macro class Value implements ClassDeclarationsMacro, ClassTypesMacro {
  final ValueImpl _impl = const ValueImpl();

  const Value();

  @override
  Future<void> buildDeclarationsForClass(
          ClassDeclaration clazz, MemberDeclarationBuilder builder) =>
      _impl.buildDeclarationsForClass(clazz, builder);

  @override
  FutureOr<void> buildTypesForClass(
          ClassDeclaration clazz, ClassTypeBuilder builder) =>
      _impl.buildTypesForClass(clazz, builder);
}

macro class ValueBuilder implements ClassDeclarationsMacro {
  final ValueBuilderImpl _impl = const ValueBuilderImpl();

  const ValueBuilder();

  @override
  Future<void> buildDeclarationsForClass(
          ClassDeclaration clazz, MemberDeclarationBuilder builder) =>
      _impl.buildDeclarationsForClass(clazz, builder);
}

macro class SerializersFor implements VariableDefinitionMacro {
  final List<Type> types;

  const SerializersFor(this.types);

  @override
  Future<void> buildDefinitionForVariable(
      VariableDeclaration variable, VariableDefinitionBuilder builder) async {
    final impl = SerializersForImpl(types);
    await impl.buildDefinitionForVariable(variable, builder);
  }
}

class HasBuilder {}

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

const Validate = 'validate';

class Serializers {
  final List<Serializer> serializers = [];
}

class Serializer {
  String forType;

  Serializer({required this.forType});
}

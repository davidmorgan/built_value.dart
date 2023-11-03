import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

import 'value_builder_impl.dart';
import 'value_impl.dart';

macro class Value implements ClassDeclarationsMacro, ClassTypesMacro {
  final ValueImpl _impl = const ValueImpl();

  const Value();

  @override
  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz,
      MemberDeclarationBuilder builder) => _impl.buildDeclarationsForClass(clazz, builder);

  @override
  FutureOr<void> buildTypesForClass(
      ClassDeclaration clazz, ClassTypeBuilder builder) => _impl.buildTypesForClass(clazz, builder);
}

final fields = <String, List<(String, bool, String)>>{};
final completers = <String, Completer<void>>{};

macro class ValueBuilder implements ClassDeclarationsMacro {
  final ValueBuilderImpl _impl = const ValueBuilderImpl();

  const ValueBuilder();

  @override
  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz,
      MemberDeclarationBuilder builder) => _impl.buildDeclarationsForClass(clazz, builder);
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

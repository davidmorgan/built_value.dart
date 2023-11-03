import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

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


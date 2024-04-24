import 'dart:async';

import 'package:macros/macros.dart';

macro class BuiltValueMacro implements ClassTypesMacro {
  const BuiltValueMacro();

  @override
  Future<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    final builderName = '${clazz.identifier.name}Builder';
    final builtValueMacroBuilderIdentifier = await builder.resolveIdentifier(
      Uri.parse('package:built_value_macro/built_value_macro.dart'),
      'BuiltValueMacroBuilder');
    builder.declareType(builderName, DeclarationCode.fromParts([
      '@',
      builtValueMacroBuilderIdentifier,
      '() ',
      'class $builderName {}',
    ]));
  }
}

macro class BuiltValueMacroBuilder implements ClassDeclarationsMacro {
  const BuiltValueMacroBuilder();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
    var className = clazz.identifier.name;
    className = className.substring(className.length - 'Builder'.length);
    final getters =
    //builder.report(Diagnostic(DiagnosticMessage('whoops'), Severity.error));
  }
}

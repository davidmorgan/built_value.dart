import 'package:_fe_analyzer_shared/src/macros/api.dart';

/// Macro that adds a `String` getter called `x` that return `OK`.
macro class DeclareX implements ClassDeclarationsMacro  {
  const DeclareX();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    builder.declareInType(DeclarationCode.fromString('String get x => "OK";'));
  }
}

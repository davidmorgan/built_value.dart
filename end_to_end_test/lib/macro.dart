import 'package:_fe_analyzer_shared/src/macros/api.dart';
import 'package:built_collection/built_collection.dart';

/// Macro that adds a `String` getter called `x` that return `OK`.
macro class DeclareX implements LibraryDeclarationsMacro  {
  const DeclareX();

  @override
  Future<void> buildDeclarationsForLibrary(
      Library library, DeclarationBuilder builder) async {
    var serializers = await builder.resolveIdentifier(Uri.parse('package:built_value/serializer.dart'), 'Serializers');
    var serializersFor = await builder.resolveIdentifier(Uri.parse('package:built_value/serializer.dart'), 'SerializersFor');
    builder.declareInLibrary(DeclarationCode.fromParts([
      '@',
      serializersFor,
      '(const [',
      'GenericValue'
      '])',
      'final ',
      serializers,
      ' serializers = _\$serializers;']));
  }
}

macro class DeclareY implements ClassDeclarationsMacro  {
  const DeclareY();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, DeclarationBuilder builder) async {
    var name = clazz.identifier.name;
    if (name.startsWith('_\$')) name = name.substring(2);
    name = '${name}Enum';
    final enumClass = await builder.resolveIdentifier(Uri.parse('package:built_value/built_value.dart'), 'EnumClass');
    final builtSet = await builder.resolveIdentifier(Uri.parse('package:built_collection/src/set.dart'), 'BuiltSet');
    builder.declareInLibrary(DeclarationCode.fromParts([
'''
class ${name} extends ''', enumClass, ''' {
  static const ${name} yes = _\$yes;
  static const ${name} no = _\$no;
  static const ${name} maybe = _\$maybe;

  const ${name}._(super.name);

  static ''', builtSet, '''<${name}> get values => _\$values;
  static ${name} valueOf(String name) => _\$valueOf(name);
}
''']));
  }
}

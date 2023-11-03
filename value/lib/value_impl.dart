import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

class ValueImpl {
  const ValueImpl();

  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    fields[clazz.identifier.name] = [];
    for (final field in await builder.fieldsOf(clazz)) {
      fields[clazz.identifier.name]!.add((
        (field.type as NamedTypeAnnotation).identifier.name,
        field.type.isNullable,
        field.identifier.name
      ));
    }
    completers[clazz.identifier.name] ??= Completer();
    completers[clazz.identifier.name]!.complete();

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

    parts.addAll([clazz.identifier.name, '._({']);

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

  FutureOr<void> buildTypesForClass(
      ClassDeclaration clazz, ClassTypeBuilder builder) {
    /*final parts = <Object>[];
    final builderType = '${clazz.identifier.name}Builder';

    parts.addAll([
      '@Value() ',
      'class $builderType {}',
    ]);

    builder.declareType(builderType, DeclarationCode.fromParts(parts));*/
    if (clazz.identifier.name == 'SimpleValue') {
      builder.declareType('ValueNullFieldError', DeclarationCode.fromString('''
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
      'Tried to construct class "\$type" with null for non-nullable field "\$field".';
}
'''));
    }
  }
}

final fields = <String, List<(String, bool, String)>>{};
final completers = <String, Completer<void>>{};

class ValueBuilderImpl {
  const ValueBuilderImpl();

  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    final baseName = clazz.identifier.name.replaceAll('Builder', '');
    completers[baseName] ??= Completer();
    await completers[baseName]!;
    final parts = <Object>[];

    for (final field in fields[baseName]!) {
      // TODO: how to check if it's a nestable type.
      if (field.$1 == 'SimpleValue') {
        parts.addAll([
          field.$1,
          'Builder ',
          field.$3,
          ' = ${field.$1}Builder();',
        ]);
      } else {
        parts.addAll([
          field.$1,
          '? ',
          field.$3,
          ';',
        ]);
      }
    }

    parts.addAll(['$baseName build() {', 'return $baseName._(']);

    for (final field in fields[baseName]!) {
      // TODO: how to check if it's a nestable type.
      if (field.$1 == 'SimpleValue') {
        parts.addAll([
          field.$3,
          ': ',
          field.$3,
          '.build(),',
        ]);
      } else {
        if (field.$2) {
          parts.addAll([
            field.$3,
            ': ',
            field.$3,
            ',',
          ]);
        } else {
          parts.addAll([
            field.$3,
            ': ',
            'ValueNullFieldError.checkNotNull(',
            field.$3,
            ", '$baseName', r'${field.$3}'),",
          ]);
        }
      }
    }

    parts.addAll([');}']);

    builder.declareInType(DeclarationCode.fromParts(parts));
  }
}

import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

import 'channel.dart';

class ValueBuilderImpl {
  const ValueBuilderImpl();

  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final baseName = clazz.identifier.name.replaceAll('Builder', '');
    final typeDeclarationIdentifier =
        await builder.resolveIdentifier(clazz.library.uri, baseName);
    final typeDeclaration =
        await builder.typeDeclarationOf(typeDeclarationIdentifier);
    //completers[baseName] ??= Completer();
    //await completers[baseName]!;
    //final metadata = metadatas[baseName]!;
    final hasBuilderIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'HasBuilder');
    final hasBuilderType = await builder
        .resolve(NamedTypeAnnotationCode(name: hasBuilderIdentifier));
    final metadata = ValueMetadata();
    for (final field in await builder.fieldsOf(typeDeclaration)) {
      final type = (field.type as NamedTypeAnnotation).identifier.name;
      final resolvedType = await builder.resolve(field.type.code);
      metadata.fields.add(FieldMetadata(
          type: type,
          isNullable: field.type.isNullable,
          // TODO: how to determine whether the type has a builder.
          typeHasBuilder: await resolvedType.isSubtypeOf(hasBuilderType),
          name: field.identifier.name));
    }
    final parts = <Object>[];

    for (final field in metadata.fields) {
      if (field.typeHasBuilder) {
        parts.addAll([
          field.type,
          'Builder ',
          field.name,
          ' = ${field.type}Builder();',
        ]);
      } else {
        parts.addAll([
          field.type,
          '? ',
          field.name,
          ';',
        ]);
      }
    }

    parts.addAll(['$baseName build() {', 'return $baseName._(']);
    final valueNullFieldErrorIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'ValueNullFieldError');

    for (final field in metadata.fields) {
      if (field.typeHasBuilder) {
        parts.addAll([
          field.name,
          ': ',
          field.name,
          '.build(),',
        ]);
      } else {
        if (field.isNullable) {
          parts.addAll([
            field.name,
            ': ',
            field.name,
            ',',
          ]);
        } else {
          parts.addAll([
            field.name,
            ': ',
            valueNullFieldErrorIdentifier,
            '.checkNotNull(',
            field.name,
            ", '$baseName', r'${field.name}'),",
          ]);
        }
      }
    }

    parts.addAll([');}']);

    parts.addAll([
      'void replace($baseName other) {',
    ]);

    for (final field in metadata.fields) {
      if (field.typeHasBuilder) {
        parts.addAll([
          field.name,
          '= other.',
          field.name,
          '.toBuilder();',
        ]);
      } else {
        parts.addAll([
          field.name,
          '= other.',
          field.name,
          ';',
        ]);
      }
    }

    parts.addAll([
      '}',
    ]);

    builder.declareInType(DeclarationCode.fromParts(parts));
  }
}

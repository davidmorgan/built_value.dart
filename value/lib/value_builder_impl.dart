import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

import 'channel.dart';

class ValueBuilderImpl {
  const ValueBuilderImpl();

  Future<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    final baseName = clazz.identifier.name.replaceAll('Builder', '');
    completers[baseName] ??= Completer();
    await completers[baseName]!;
    final metadata = metadatas[baseName]!;
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

    builder.declareInType(DeclarationCode.fromParts(parts));
  }
}

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

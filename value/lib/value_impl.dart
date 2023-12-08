import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';
import 'package:_fe_analyzer_shared/src/macros/executor/introspection_impls.dart';

import 'channel.dart';

class ValueImpl {
  const ValueImpl();

  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    metadatas.remove(clazz.identifier.name);
    final metadata = ValueMetadata();
    final hasBuilderIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'HasBuilder');
    final hasBuilderType = await builder
        .resolve(NamedTypeAnnotationCode(name: hasBuilderIdentifier));
    for (final field in await builder.fieldsOf(clazz)) {
      final type = (field.type as NamedTypeAnnotation).identifier.name;
      final resolvedType = await builder.resolve(field.type.code);
      metadata.fields.add(FieldMetadata(
          type: type,
          isNullable: field.type.isNullable,
          // TODO: how to determine whether the type has a builder.
          typeHasBuilder: await resolvedType.isSubtypeOf(hasBuilderType),
          name: field.identifier.name));
    }
    metadatas[clazz.identifier.name] = metadata;
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
    parts.add('})');
    final methods = await builder.methodsOf(clazz);
    // Annotation check doesn't seem to work.
    final validateMethods = methods.where((m) =>
        m.metadata.any((a) =>
            a is IdentifierMetadataAnnotation &&
            a.identifier.name == 'Validate') ||
        m.identifier.name == 'validate');
    if (validateMethods.isNotEmpty) {
      parts.add("{ ${validateMethods.first.identifier.name}(); }");
    } else {
      parts.add(';');
    }

    parts.addAll([
      builderType,
      ' toBuilder() => $builderType()..replace(this);',
    ]);

    parts.addAll([
      clazz.identifier.name,
      ' rebuild(void Function($builderType) updates) {',
      'final builder = toBuilder();',
      'updates(builder);',
      'return builder.build();',
      '}'
    ]);

    parts.addAll([
      'bool operator== (Object other) =>',
      'other is ${clazz.identifier.name} &&'
    ]);

    for (final field in metadata.fields) {
      parts.addAll([
        field.name,
        '== other.',
        field.name,
        ' &&',
      ]);
    }
    parts.removeLast();
    parts.addAll([';']);

    builder.declareInType(DeclarationCode.fromParts(parts));

    // Doesn't seem to do anything.
    /*
    builder.report(Diagnostic(
        DiagnosticMessage('oh no', target: clazz.asDiagnosticTarget),
        Severity.error));*/
  }

  Future<void> buildTypesForClass(
      ClassDeclaration clazz, ClassTypeBuilder builder) async {
    // This should create the builder and trigger the builder macro on it; the
    // creating works but not the macro trigger.
    /*final builderType = '${clazz.identifier.name}Builder';
    final parts = <Object>[];
    final valueBuilderIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'ValueBuilder');

    parts.addAll([
      '@',
      valueBuilderIdentifier,
      '() ',
      ' class $builderType {}',
    ]);

    builder.declareType(builderType, DeclarationCode.fromParts(parts));*/

    // This should add the HasBuilder marker interface, doesn't seem to work.
    /*
    final hasBuilderIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'HasBuilder');
    builder.appendInterfaces(
        [NamedTypeAnnotationCode(name: hasBuilderIdentifier)]);
    */
  }
}

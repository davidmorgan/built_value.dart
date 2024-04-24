import 'dart:async';

import 'package:macros/macros.dart';

macro class BuiltValueMacro implements ClassTypesMacro, ClassDeclarationsMacro {
  const BuiltValueMacro();

  @override
  Future<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    final builderName = '${clazz.identifier.name}Builder';
    final builtValueMacroBuilderIdentifier = await builder.resolveIdentifier(
      Uri.parse('package:built_value_macro/built_value_macro.dart'),
      'BuiltValueBuilderMacro');
    builder.declareType(builderName, DeclarationCode.fromParts([
      '@',
      builtValueMacroBuilderIdentifier,
      '() ',
      'class $builderName {}',
    ]));
  }

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final boolIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'bool');
    final intIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'int');
    final stringIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'String');
    final objectIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'Object');
    final identicalIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'identical');
    final overrideIdentifier = await builder.resolveIdentifier(Uri.parse('dart:core'), 'override');
    final jcIdentifier = await builder.resolveIdentifier(Uri.parse('package:built_value_macro/built_value_macro.dart'), '\$jc');
    final jfIdentifier = await builder.resolveIdentifier(Uri.parse('package:built_value_macro/built_value_macro.dart'), '\$jf');
    final newBuiltValueToStringHelperIdentifier = await builder.resolveIdentifier(Uri.parse('package:built_value_macro/built_value_macro.dart'), 'newBuiltValueToStringHelper');
    final builtValueMacroNullErrorIdentifier = await builder.resolveIdentifier(
      Uri.parse('package:built_value_macro/built_value_macro.dart'), 'BuiltValueMacroNullError');

    final name = clazz.identifier.name;
    final builderName = '${name}Builder';
    builder.declareInType(DeclarationCode.fromParts([
      'factory $name([void Function($builderName)? updates])'
      '=> (new $builderName()..update(updates)).build();'
    ]));

    final fields = await builder.fieldsOf(clazz);
    builder.declareInType(DeclarationCode.fromParts([
      '$name._({',
      fields.map((field) {
        var maybeRequired = field.type.isNullable ? '' : 'required ';
        return '${maybeRequired}this.${field.identifier.name}';
      }).join(', '),
      '}) {',
      for (final field in fields) ...[
        builtValueMacroNullErrorIdentifier,
        '.checkNotNull(',
        field.identifier,
        ',"${clazz.identifier.name}"',
        ',"${field.identifier.name}");',
      ],
      '}',
    ]));

    builder.declareInType(DeclarationCode.fromParts([
      boolIdentifier,
      ' operator==(',
      objectIdentifier,
      ' other) {',
      'if (',
      identicalIdentifier,
      '(other, this)) return true;'
      'return other is ',
      clazz.identifier,
      for (final field in fields) ...[
        ' && ',
        field.identifier.name == 'other' ? 'this.other' : field.identifier.name,
        '==',
        'other.',
        field.identifier.name,
      ],
      ';',
      '}',
    ]));

    builder.declareInType(DeclarationCode.fromParts([
      '@',
      overrideIdentifier,
      ' ',
      intIdentifier,
      ' get hashCode {',
      'var _\$hash = 0;',
      for (final field in fields) ...[
        '_\$hash = ',
        jcIdentifier,
        '(_\$hash,',
        field.identifier.name,
        '.hashCode);'
      ],
      '_\$hash = ',
      jfIdentifier,
      '(_\$hash);',
      'return _\$hash;',
      '}',
    ]));

    builder.declareInType(DeclarationCode.fromParts([
      '@',
      overrideIdentifier,
      ' ',
      stringIdentifier,
      ' toString() {',
      'return (',
      newBuiltValueToStringHelperIdentifier,
      '("',
      clazz.identifier.name,
      '")',
      for (final field in fields) ...[
        '..add("',
        field.identifier.name,
        '",',
        field.identifier,
        ')',
      ],
      ').toString();',
      '}',
     ]));
  }
}

macro class BuiltValueBuilderMacro implements ClassDeclarationsMacro {
  const BuiltValueBuilderMacro();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration builderClass, MemberDeclarationBuilder builder) async {
    final builtValueMacroNullErrorIdentifier = await builder.resolveIdentifier(
      Uri.parse('package:built_value_macro/built_value_macro.dart'), 'BuiltValueMacroNullError');

    var className = builderClass.identifier.name;
    className = className.substring(0, className.length - 'Builder'.length);
    final clazzIdentifier = await builder.resolveIdentifier(builderClass.library.uri, className);
    builder.declareInType(DeclarationCode.fromParts([
      clazzIdentifier,
      '? _\$v;',
    ]));

    final clazz = await builder.typeDeclarationOf(clazzIdentifier);
    final fields = await builder.fieldsOf(clazz);

    for (final field in fields) {
      final fieldType = (field.type as NamedTypeAnnotation).identifier;
      builder.declareInType(DeclarationCode.fromParts([
        fieldType,
        '? _',
        field.identifier.name,
        ';',
      ]));

      builder.declareInType(DeclarationCode.fromParts([
        fieldType,
        '? get ',
        field.identifier.name,
        ' => _\$this._',
        field.identifier.name,
        ';',
      ]));

      builder.declareInType(DeclarationCode.fromParts([
        'set ',
        field.identifier.name,
        '(',
        fieldType,
        '? ',
        field.identifier.name,
        ')',
        ' => _\$this._',
        field.identifier.name,
        ' = ',
        field.identifier.name,
        ';',
      ]));
    }

    builder.declareInType(DeclarationCode.fromParts([
      builderClass.identifier.name,
      '();',
    ]));

      builder.declareInType(DeclarationCode.fromParts([
        builderClass.identifier,
        ' get _\$this {'
        'final \$v = _\$v;',
        'if (\$v != null) {',
        for (final field in fields) ...[
        field.identifier.name,
        ' = ',
        '\$v.',
        field.identifier.name,
        ';',
        ],
        '_\$v = null;',
        '}',
        'return this;',
        '}',
      ]));

    builder.declareInType(
      DeclarationCode.fromParts([
        'void replace(',
        clazz.identifier,
        ' other) {'
        '_\$v = other;',
        '}',
      ]));

    builder.declareInType(
        DeclarationCode.fromParts([
          'void update(void Function(',
          builderClass.identifier,
          ')? updates) {',
          'if (updates != null) updates(this);'
          '}',
        ]));

    builder.declareInType(
        DeclarationCode.fromParts([
          clazz.identifier,
          ' build() {',
          'final _\$result = ',
          clazz.identifier,
          '._(',
          for (final field in fields) ...[
            field.identifier.name,
            ': ',
            builtValueMacroNullErrorIdentifier,
            '.checkNotNull(',
            field.identifier.name,
            ',',
            "r'$className'",
            ',',
            "r'${field.identifier.name}'",
            '),'
          ],
          ');',
          'replace(_\$result);',
          'return _\$result;',
          '}',
        ]));


    //builder.report(Diagnostic(DiagnosticMessage('whoops'), Severity.error));
  }
}

class BuiltValueMacroNullError extends Error {
  final String type;
  final String field;

  BuiltValueMacroNullError(this.type, this.field);

  static T checkNotNull<T>(T? value, String type, String field) {
    if (value == null) {
      throw BuiltValueMacroNullError(type, field);
    }
    return value;
  }

  @override
  String toString() =>
      'Tried to construct class "$type" with null for non-nullable field "$field".';
}

/// For use by generated code in calculating hash codes. Do not use directly.
int $jc(int hash, int value) {
  // Jenkins hash "combine".
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

/// For use by generated code in calculating hash codes. Do not use directly.
int $jf(int hash) {
  // Jenkins hash "finish".
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Function that returns a [BuiltValueToStringHelper].
typedef BuiltValueToStringHelperProvider = BuiltValueToStringHelper Function(
    String className);

/// Function used by generated code to get a [BuiltValueToStringHelper].
/// Set this to change built_value class toString() output. Built-in examples
/// are [IndentingBuiltValueToStringHelper], which is the default, and
/// [FlatBuiltValueToStringHelper].
BuiltValueToStringHelperProvider newBuiltValueToStringHelper =
    (String className) => IndentingBuiltValueToStringHelper(className);

/// Interface for built_value toString() output helpers.
///
/// Note: this is an experimental feature. API may change without a major
/// version increase.
abstract class BuiltValueToStringHelper {
  /// Add a field and its value.
  void add(String field, Object? value);

  /// Returns to completed toString(). The helper may not be used after this
  /// method is called.
  @override
  String toString();
}

/// A [BuiltValueToStringHelper] that produces multi-line indented output.
class IndentingBuiltValueToStringHelper implements BuiltValueToStringHelper {
  StringBuffer? _result = StringBuffer();

  IndentingBuiltValueToStringHelper(String className) {
    _result!
      ..write(className)
      ..write(' {\n');
    _indentingBuiltValueToStringHelperIndent += 2;
  }

  @override
  void add(String field, Object? value) {
    if (value != null) {
      _result!
        ..write(' ' * _indentingBuiltValueToStringHelperIndent)
        ..write(field)
        ..write('=')
        ..write(value)
        ..write(',\n');
    }
  }

  @override
  String toString() {
    _indentingBuiltValueToStringHelperIndent -= 2;
    _result!
      ..write(' ' * _indentingBuiltValueToStringHelperIndent)
      ..write('}');
    var stringResult = _result.toString();
    _result = null;
    return stringResult;
  }
}

int _indentingBuiltValueToStringHelperIndent = 0;

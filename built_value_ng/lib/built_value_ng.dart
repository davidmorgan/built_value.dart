import 'package:ng_client/ng_client.dart';
import 'package:ng_model/augmentation.dart';
import 'package:ng_model/query.dart';
import 'package:ng_model/source.dart';

class BuiltValueNg implements Generator {
  final Map<Identifier, List<Field>> fields = {};

  final Query classesWithAnnotation = Query.classesWithAnnotation('BuiltValue');

  @override
  void start(NgService service) {
    service.subscribe(classesWithAnnotation);
  }

  @override
  void notify(NgService service, SourceChange change) {
    if (classesWithAnnotation.matches(change)) {
      if (change is SourceChangeAdd) {
        service.subscribe(Query.fieldsOf(change.identifier));
        fields[change.identifier] = [];
        toEmit.add(change.identifier);
      } else if (change is SourceChangeRemove) {
        service.unsubscribe(Query.fieldsOf(change.identifier));
        fields.remove([change.identifier]);
        toEmit.add(change.identifier);
      }
    } else if (change.entity['type'] == 'field') {
      final field = Field(type: change.entity['fieldType'], name: change.identifier.member!);
      if (change is SourceChangeAdd) {
        fields[change.identifier.withoutMember]!.add(field);
      } else if (change is SourceChangeRemove) {
        fields[change.identifier.withoutMember]!.remove(field);
      } else {
        fields[change.identifier.withoutMember]!
            .removeWhere((f) => f.name == field.name);
        fields[change.identifier.withoutMember]!.add(field);
      }
      toEmit.add(change.identifier.withoutMember);
    }
  }

final toEmit = <Identifier>{};
  void flush(NgService service) {
    emit(service, toEmit);
    toEmit.clear();
  }

  void emit(NgService service, Iterable<Identifier> toEmit) {
    for (final identifier in toEmit) {
      service.unemitAll(identifier);

      generateValueType(service, identifier);
      generateBuilder(service, identifier);
    }
  }

  void generateValueType(NgService service, Identifier identifier) {
    final fields = this.fields[identifier];
    if (fields == null) return;

    final result = StringBuffer();

    final name = identifier.name;
    final builderName = '${name}Builder';
    result.write('augment class $name {');
    result.write(
      'factory $name([void Function($builderName)? updates])'
      '=> (new $builderName()..update(updates)).build();\n');

    result.write([
      '$name._({',
      fields.map((field) {
        var maybeRequired = field.type.endsWith('?') ? '' : 'required ';
        return '${maybeRequired}this.${field.name}';
      }).join(', '),
      '}) {\n',
      for (final field in fields) ...[
        'BuiltValueNullFieldError.checkNotNull(',
        field.name,
        ',"$name"',
        ',"${field.name}");\n',
      ],
      '}\n',
    ].join(''));

    result.write([
      '@override bool operator==(Object other) {',
      'if (identical(other, this)) return true;'
      'return other is $name',
      for (final field in fields) ...[
        ' && ',
        field.name == 'other' ? 'this.other' : field.name,
        '==',
        'other.',
        field.name,
      ],
      ';\n',
      '}\n',
    ].join(''));

    result.write([
      '@override int get hashCode {',
      'var _\$hash = 0;\n',
      for (final field in fields) ...[
        '_\$hash = \$jc(_\$hash,',
        field.name,
        '.hashCode);\n'
      ],
      '_\$hash = \$jf(_\$hash);',
      'return _\$hash;',
      '}\n',
    ].join(''));

    result.write([
      '@override String toString() {\n',
      'return (newBuiltValueToStringHelper("',
      name,
      '")',
      for (final field in fields) ...[
        '..add("',
        field.name,
        '",',
        field.name,
        ')',
      ],
      ').toString();\n',
      '}\n',
     ].join(''));

    result.write('}');

    service.emit(Augmentation.code(identifier.uri, result.toString()));
  }

  void generateBuilder(NgService service, Identifier identifier) {
    final fields = this.fields[identifier];
    if (fields == null) return;

    final result = StringBuffer();
    final className = identifier.name;
    final builderName = '${className}Builder';

    result.write('class $builderName {');
    result.write([
      className,
      '? _\$v;',
    ].join(''));

    for (final field in fields) {
      result.write([
        field.type,
        '? _',
        field.name,
        ';\n',
      ].join(''));

      result.write([
        field.type,
        '? get ',
        field.name,
        ' => _\$this._',
        field.name,
        ';\n',
      ].join(''));

      result.write([
        'set ',
        field.name,
        '(',
        field.type,
        '? ',
        field.name,
        ')',
        ' => _\$this._',
        field.name,
        ' = ',
        field.name,
        ';\n',
      ].join(''));
    }

    result.write([
      builderName,
      '();\n',
    ].join(''));

    result.write([
        builderName,
        ' get _\$this {'
        'final \$v = _\$v;',
        'if (\$v != null) {',
        for (final field in fields) ...[
        field.name,
        ' = ',
        '\$v.',
        field.name,
        ';\n',
        ],
        '_\$v = null;\n',
        '}',
        'return this;\n',
        '}',
      ].join(''));

    result.write([
        'void replace(',
        className,
        ' other) {\n'
        '_\$v = other;\n',
        '}\n',
      ].join(''));

    result.write([
        'void update(void Function(',
        builderName,
        ')? updates) {',
        'if (updates != null) updates(this);'
        '}\n',
      ].join(''));

    result.write([
          className,
          ' build() {',
          'final _\$result = ',
          className,
          '._(',
          for (final field in fields) ...[
            field.name,
            ': ',
            'BuiltValueNullFieldError.checkNotNull(',
            field.name,
            ',',
            "r'$className'",
            ',',
            "r'${field.name}'",
            '),'
          ],
          ');\n',
          'replace(_\$result);\n',
          'return _\$result;\n',
          '}\n',
        ].join(''));

    result.write('}\n');

    service.emit(Augmentation.code(identifier.uri, result.toString()));
  }

  String toString() => 'BuiltValueNg';
}

class Field {
  final String type;
  final String name;

  Field({required this.type, required this.name});

  @override
  bool operator ==(Object other) => other is Field && other.type == type && other.name == name;

  @override
  int get hashCode => type.hashCode ^ name.hashCode;
}

import 'dart:async';

// Pass some data between macros.

// Don't do this! It's against spec and could break at any time. Issue for
// adding the needed introspection support:
//
// https://github.com/dart-lang/language/issues/3442

final metadatas = <String, ValueMetadata>{};
final completers = <String, Completer<void>>{};

class ValueMetadata {
  final List<FieldMetadata> fields = [];
}

class FieldMetadata {
  final String type;
  final bool typeHasBuilder;
  final bool isNullable;
  final String name;

  FieldMetadata(
      {required this.type,
      required this.typeHasBuilder,
      required this.isNullable,
      required this.name});
}

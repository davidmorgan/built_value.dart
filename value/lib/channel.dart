import 'dart:async';

final metadatas = <String, ValueMetadata>{};
final completers = <String, Completer<void>>{};

class ValueMetadata {
  final List<FieldMetadata> fields = [];
}

class FieldMetadata {
  final String type;
  final bool isNullable;
  final String name;

  FieldMetadata(
      {required this.type, required this.isNullable, required this.name});
}

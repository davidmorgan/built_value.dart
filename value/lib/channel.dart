import 'dart:async';

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

import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

class SerializersForImpl {
  final List<Type> types;

  SerializersForImpl(this.types);

  Future<void> buildDefinitionForVariable(
      VariableDeclaration variable, VariableDefinitionBuilder builder) async {
    final parts = <Object>[];
    final serializersIdentifier = await builder.resolveIdentifier(
        Uri.parse('package:value/value.dart'), 'Serializers');
    parts.addAll([
      serializersIdentifier,
      '();',
    ]);

    builder.augment(initializer: ExpressionCode.fromParts(parts));
  }
}

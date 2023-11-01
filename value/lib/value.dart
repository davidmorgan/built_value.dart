import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro class Value implements ClassDeclarationsMacro, ClassTypesMacro {
  const Value();

  @override
  FutureOr<void> buildDeclarationsForClass(IntrospectableClassDeclaration clazz, MemberDeclarationBuilder builder) {
    if (clazz.identifier.name == 'SimpleValue') {
    builder.declareInType(DeclarationCode.fromString('''
factory SimpleValue(void Function(SimpleValueBuilder) updates) {
  final builder = SimpleValueBuilder();
  updates(builder);
  return builder.build();
}

SimpleValue._({required this.anInt});

SimpleValueBuilder toBuilder() => SimpleValueBuilder()..anInt = anInt;

SimpleValue rebuild(void Function(SimpleValueBuilder) updates) {
  final builder = toBuilder();
  updates(builder);
  return builder.build();
}
'''));
    } else if (clazz.identifier.name == 'CompoundValue') {
builder.declareInType(DeclarationCode.fromString('''
factory CompoundValue(void Function(CompoundValueBuilder) updates) {
  final builder = CompoundValueBuilder();
  updates(builder);
  return builder.build();
}

CompoundValue._({required this.simpleValue});

CompoundValueBuilder toBuilder() => CompoundValueBuilder()..simpleValue = simpleValue.toBuilder();

CompoundValue rebuild(void Function(CompoundValueBuilder) updates) {
  final builder = toBuilder();
  updates(builder);
  return builder.build();
}
'''));
    } else {
      throw 'unsupported';
    }
  }

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) {
    if (clazz.identifier.name == 'SimpleValue') {
    builder.declareType('SimpleValueBuilder', DeclarationCode.fromString(
      '''
class SimpleValueBuilder {
  int? anInt;

  SimpleValue build() => SimpleValue._(anInt: anInt!);
}
'''
    ));
    } else if (clazz.identifier.name == 'CompoundValue') {
builder.declareType('CompoundValueBuilder', DeclarationCode.fromString(
      '''
class CompoundValueBuilder {
  SimpleValueBuilder simpleValue = SimpleValueBuilder();

  CompoundValue build() => CompoundValue._(simpleValue: simpleValue.build());
}
'''
    ));
    } else {
      throw 'unsupported';
    }
  }
}

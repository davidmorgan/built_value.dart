// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_json.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<StandardJsonValue> _$standardJsonValueSerializer =
    new _$StandardJsonValueSerializer();
Serializer<ComplexValue> _$complexValueSerializer =
    new _$ComplexValueSerializer(); //@DeclareY()

class _$StandardJsonValueSerializer
    implements StructuredSerializer<StandardJsonValue> {
  @override
  final Iterable<Type> types = const [StandardJsonValue, _$StandardJsonValue];
  @override
  final String wireName = 'StandardJsonValue';

  @override
  Iterable<Object?> serialize(Serializers serializers, StandardJsonValue object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'number',
      serializers.serialize(object.number, specifiedType: const FullType(num)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'value',
      serializers.serialize(object.value,
          specifiedType: const FullType(ComplexValue)),
      'keyValues',
      serializers.serialize(object.keyValues,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(JsonObject)])),
      'nullsInList',
      serializers.serialize(object.nullsInList,
          specifiedType:
              const FullType(BuiltList, const [const FullType.nullable(int)])),
      'nullsInSet',
      serializers.serialize(object.nullsInSet,
          specifiedType: const FullType(
              BuiltList, const [const FullType.nullable(String)])),
      'nullsInMap',
      serializers.serialize(object.nullsInMap,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType.nullable(int)])),
      'objects',
      serializers.serialize(object.objects,
          specifiedType:
              const FullType(BuiltList, const [const FullType(Object)])),
    ];
    Object? value;
    value = object.strings;
    if (value != null) {
      result
        ..add('strings')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.object;
    if (value != null) {
      result
        ..add('object')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(ComplexValueInterface)));
    }
    return result;
  }

  @override
  StandardJsonValue deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new StandardJsonValueBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'number':
          result.number = serializers.deserialize(value,
              specifiedType: const FullType(num))! as num;
          break;
        case 'text':
          result.text = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'value':
          result.value.replace(serializers.deserialize(value,
              specifiedType: const FullType(ComplexValue))! as ComplexValue);
          break;
        case 'keyValues':
          result.keyValues.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType(JsonObject)
              ]))!);
          break;
        case 'strings':
          result.strings.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nullsInList':
          result.nullsInList.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType.nullable(int)]))!
              as BuiltList<Object?>);
          break;
        case 'nullsInSet':
          result.nullsInSet.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType.nullable(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nullsInMap':
          result.nullsInMap.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(int)
              ]))!);
          break;
        case 'object':
          result.object = serializers.deserialize(value,
                  specifiedType: const FullType(ComplexValueInterface))
              as ComplexValueInterface?;
          break;
        case 'objects':
          result.objects.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(Object)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

//@DeclareY()
class _$ComplexValueSerializer implements StructuredSerializer<ComplexValue> {
  @override
  final Iterable<Type> types = const [ComplexValue, _$ComplexValue];
  @override
  final String wireName = 'ComplexValue';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplexValue object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'primitive',
      serializers.serialize(object.primitive,
          specifiedType: const FullType(int)),
      'value',
      serializers.serialize(object.value,
          specifiedType: const FullType(SimpleValue)),
    ];
    Object? value;
    value = object.nullablePrimitive;
    if (value != null) {
      result
        ..add('nullablePrimitive')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.nullablePrimitiveDoNotUse;
    if (value != null) {
      result
        ..add('nullablePrimitiveDoNotUse')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.nullableValue;
    if (value != null) {
      result
        ..add('nullableValue')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(SimpleValue)));
    }
    value = object.nullableValueDoNotUse;
    if (value != null) {
      result
        ..add('nullableValueDoNotUse')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(SimpleValue)));
    }
    return result;
  }

  @override
  ComplexValue deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComplexValueBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'primitive':
          result.primitive = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'nullablePrimitive':
          result.nullablePrimitive = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'nullablePrimitiveDoNotUse':
          result.nullablePrimitiveDoNotUse = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'value':
          result.value.replace(serializers.deserialize(value,
              specifiedType: const FullType(SimpleValue))! as SimpleValue);
          break;
        case 'nullableValue':
          result.nullableValue.replace(serializers.deserialize(value,
              specifiedType: const FullType(SimpleValue))! as SimpleValue);
          break;
        case 'nullableValueDoNotUse':
          result.nullableValueDoNotUse.replace(serializers.deserialize(value,
              specifiedType: const FullType(SimpleValue))! as SimpleValue);
          break;
      }
    }

    return result.build();
  }
}

class _$StandardJsonValue extends StandardJsonValue {
  @override
  final num number;
  @override
  final String text;
  @override
  final ComplexValue value;
  @override
  final BuiltMap<String, JsonObject> keyValues;
  @override
  final BuiltList<String>? strings;
  @override
  final BuiltList<int?> nullsInList;
  @override
  final BuiltList<String?> nullsInSet;
  @override
  final BuiltMap<String, int?> nullsInMap;
  @override
  final ComplexValueInterface? object;
  @override
  final BuiltList<Object> objects;

  factory _$StandardJsonValue(
          [void Function(StandardJsonValueBuilder)? updates]) =>
      (new StandardJsonValueBuilder()..update(updates))._build();

  _$StandardJsonValue._(
      {required this.number,
      required this.text,
      required this.value,
      required this.keyValues,
      this.strings,
      required this.nullsInList,
      required this.nullsInSet,
      required this.nullsInMap,
      this.object,
      required this.objects})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        number, r'StandardJsonValue', 'number');
    BuiltValueNullFieldError.checkNotNull(text, r'StandardJsonValue', 'text');
    BuiltValueNullFieldError.checkNotNull(value, r'StandardJsonValue', 'value');
    BuiltValueNullFieldError.checkNotNull(
        keyValues, r'StandardJsonValue', 'keyValues');
    BuiltValueNullFieldError.checkNotNull(
        nullsInList, r'StandardJsonValue', 'nullsInList');
    BuiltValueNullFieldError.checkNotNull(
        nullsInSet, r'StandardJsonValue', 'nullsInSet');
    BuiltValueNullFieldError.checkNotNull(
        nullsInMap, r'StandardJsonValue', 'nullsInMap');
    BuiltValueNullFieldError.checkNotNull(
        objects, r'StandardJsonValue', 'objects');
  }

  @override
  StandardJsonValue rebuild(void Function(StandardJsonValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardJsonValueBuilder toBuilder() =>
      new StandardJsonValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandardJsonValue &&
        number == other.number &&
        text == other.text &&
        value == other.value &&
        keyValues == other.keyValues &&
        strings == other.strings &&
        nullsInList == other.nullsInList &&
        nullsInSet == other.nullsInSet &&
        nullsInMap == other.nullsInMap &&
        object == other.object &&
        objects == other.objects;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, keyValues.hashCode);
    _$hash = $jc(_$hash, strings.hashCode);
    _$hash = $jc(_$hash, nullsInList.hashCode);
    _$hash = $jc(_$hash, nullsInSet.hashCode);
    _$hash = $jc(_$hash, nullsInMap.hashCode);
    _$hash = $jc(_$hash, object.hashCode);
    _$hash = $jc(_$hash, objects.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandardJsonValue')
          ..add('number', number)
          ..add('text', text)
          ..add('value', value)
          ..add('keyValues', keyValues)
          ..add('strings', strings)
          ..add('nullsInList', nullsInList)
          ..add('nullsInSet', nullsInSet)
          ..add('nullsInMap', nullsInMap)
          ..add('object', object)
          ..add('objects', objects))
        .toString();
  }
}

class StandardJsonValueBuilder
    implements Builder<StandardJsonValue, StandardJsonValueBuilder> {
  _$StandardJsonValue? _$v;

  num? _number;
  num? get number => _$this._number;
  set number(num? number) => _$this._number = number;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  ComplexValueBuilder? _value;
  ComplexValueBuilder get value => _$this._value ??= new ComplexValueBuilder();
  set value(ComplexValueBuilder? value) => _$this._value = value;

  MapBuilder<String, JsonObject>? _keyValues;
  MapBuilder<String, JsonObject> get keyValues =>
      _$this._keyValues ??= new MapBuilder<String, JsonObject>();
  set keyValues(MapBuilder<String, JsonObject>? keyValues) =>
      _$this._keyValues = keyValues;

  ListBuilder<String>? _strings;
  ListBuilder<String> get strings =>
      _$this._strings ??= new ListBuilder<String>();
  set strings(ListBuilder<String>? strings) => _$this._strings = strings;

  ListBuilder<int?>? _nullsInList;
  ListBuilder<int?> get nullsInList =>
      _$this._nullsInList ??= new ListBuilder<int?>();
  set nullsInList(ListBuilder<int?>? nullsInList) =>
      _$this._nullsInList = nullsInList;

  ListBuilder<String?>? _nullsInSet;
  ListBuilder<String?> get nullsInSet =>
      _$this._nullsInSet ??= new ListBuilder<String?>();
  set nullsInSet(ListBuilder<String?>? nullsInSet) =>
      _$this._nullsInSet = nullsInSet;

  MapBuilder<String, int?>? _nullsInMap;
  MapBuilder<String, int?> get nullsInMap =>
      _$this._nullsInMap ??= new MapBuilder<String, int?>();
  set nullsInMap(MapBuilder<String, int?>? nullsInMap) =>
      _$this._nullsInMap = nullsInMap;

  ComplexValueInterface? _object;
  ComplexValueInterface? get object => _$this._object;
  set object(ComplexValueInterface? object) => _$this._object = object;

  ListBuilder<Object>? _objects;
  ListBuilder<Object> get objects =>
      _$this._objects ??= new ListBuilder<Object>();
  set objects(ListBuilder<Object>? objects) => _$this._objects = objects;

  StandardJsonValueBuilder();

  StandardJsonValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _number = $v.number;
      _text = $v.text;
      _value = $v.value.toBuilder();
      _keyValues = $v.keyValues.toBuilder();
      _strings = $v.strings?.toBuilder();
      _nullsInList = $v.nullsInList.toBuilder();
      _nullsInSet = $v.nullsInSet.toBuilder();
      _nullsInMap = $v.nullsInMap.toBuilder();
      _object = $v.object;
      _objects = $v.objects.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandardJsonValue other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$StandardJsonValue;
  }

  @override
  void update(void Function(StandardJsonValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandardJsonValue build() => _build();

  _$StandardJsonValue _build() {
    _$StandardJsonValue _$result;
    try {
      _$result = _$v ??
          new _$StandardJsonValue._(
              number: BuiltValueNullFieldError.checkNotNull(
                  number, r'StandardJsonValue', 'number'),
              text: BuiltValueNullFieldError.checkNotNull(
                  text, r'StandardJsonValue', 'text'),
              value: value.build(),
              keyValues: keyValues.build(),
              strings: _strings?.build(),
              nullsInList: nullsInList.build(),
              nullsInSet: nullsInSet.build(),
              nullsInMap: nullsInMap.build(),
              object: object,
              objects: objects.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'value';
        value.build();
        _$failedField = 'keyValues';
        keyValues.build();
        _$failedField = 'strings';
        _strings?.build();
        _$failedField = 'nullsInList';
        nullsInList.build();
        _$failedField = 'nullsInSet';
        nullsInSet.build();
        _$failedField = 'nullsInMap';
        nullsInMap.build();

        _$failedField = 'objects';
        objects.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'StandardJsonValue', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplexValue extends ComplexValue {
  @override
  final int primitive;
  @override
  final int? nullablePrimitive;
  @override
  final int? nullablePrimitiveDoNotUse;
  @override
  final SimpleValue value;
  @override
  final SimpleValue? nullableValue;
  @override
  final SimpleValue? nullableValueDoNotUse;

  factory _$ComplexValue([void Function(ComplexValueBuilder)? updates]) =>
      (new ComplexValueBuilder()..update(updates))._build();

  _$ComplexValue._(
      {required this.primitive,
      this.nullablePrimitive,
      this.nullablePrimitiveDoNotUse,
      required this.value,
      this.nullableValue,
      this.nullableValueDoNotUse})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        primitive, r'ComplexValue', 'primitive');
    BuiltValueNullFieldError.checkNotNull(value, r'ComplexValue', 'value');
  }

  @override
  ComplexValue rebuild(void Function(ComplexValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplexValueBuilder toBuilder() => new ComplexValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplexValue &&
        primitive == other.primitive &&
        nullablePrimitive == other.nullablePrimitive &&
        nullablePrimitiveDoNotUse == other.nullablePrimitiveDoNotUse &&
        value == other.value &&
        nullableValue == other.nullableValue &&
        nullableValueDoNotUse == other.nullableValueDoNotUse;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, primitive.hashCode);
    _$hash = $jc(_$hash, nullablePrimitive.hashCode);
    _$hash = $jc(_$hash, nullablePrimitiveDoNotUse.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, nullableValue.hashCode);
    _$hash = $jc(_$hash, nullableValueDoNotUse.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplexValue')
          ..add('primitive', primitive)
          ..add('nullablePrimitive', nullablePrimitive)
          ..add('nullablePrimitiveDoNotUse', nullablePrimitiveDoNotUse)
          ..add('value', value)
          ..add('nullableValue', nullableValue)
          ..add('nullableValueDoNotUse', nullableValueDoNotUse))
        .toString();
  }
}

class ComplexValueBuilder
    implements Builder<ComplexValue, ComplexValueBuilder> {
  _$ComplexValue? _$v;

  int? _primitive;
  int? get primitive => _$this._primitive;
  set primitive(int? primitive) => _$this._primitive = primitive;

  int? _nullablePrimitive;
  int? get nullablePrimitive => _$this._nullablePrimitive;
  set nullablePrimitive(int? nullablePrimitive) =>
      _$this._nullablePrimitive = nullablePrimitive;

  int? _nullablePrimitiveDoNotUse;
  int? get nullablePrimitiveDoNotUse => _$this._nullablePrimitiveDoNotUse;
  set nullablePrimitiveDoNotUse(int? nullablePrimitiveDoNotUse) =>
      _$this._nullablePrimitiveDoNotUse = nullablePrimitiveDoNotUse;

  SimpleValueBuilder? _value;
  SimpleValueBuilder get value => _$this._value ??= new SimpleValueBuilder();
  set value(SimpleValueBuilder? value) => _$this._value = value;

  SimpleValueBuilder? _nullableValue;
  SimpleValueBuilder get nullableValue =>
      _$this._nullableValue ??= new SimpleValueBuilder();
  set nullableValue(SimpleValueBuilder? nullableValue) =>
      _$this._nullableValue = nullableValue;

  SimpleValueBuilder? _nullableValueDoNotUse;
  SimpleValueBuilder get nullableValueDoNotUse =>
      _$this._nullableValueDoNotUse ??= new SimpleValueBuilder();
  set nullableValueDoNotUse(SimpleValueBuilder? nullableValueDoNotUse) =>
      _$this._nullableValueDoNotUse = nullableValueDoNotUse;

  ComplexValueBuilder();

  ComplexValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _primitive = $v.primitive;
      _nullablePrimitive = $v.nullablePrimitive;
      _nullablePrimitiveDoNotUse = $v.nullablePrimitiveDoNotUse;
      _value = $v.value.toBuilder();
      _nullableValue = $v.nullableValue?.toBuilder();
      _nullableValueDoNotUse = $v.nullableValueDoNotUse?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplexValue other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ComplexValue;
  }

  @override
  void update(void Function(ComplexValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplexValue build() => _build();

  _$ComplexValue _build() {
    _$ComplexValue _$result;
    try {
      _$result = _$v ??
          new _$ComplexValue._(
              primitive: BuiltValueNullFieldError.checkNotNull(
                  primitive, r'ComplexValue', 'primitive'),
              nullablePrimitive: nullablePrimitive,
              nullablePrimitiveDoNotUse: nullablePrimitiveDoNotUse,
              value: value.build(),
              nullableValue: _nullableValue?.build(),
              nullableValueDoNotUse: _nullableValueDoNotUse?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'value';
        value.build();
        _$failedField = 'nullableValue';
        _nullableValue?.build();
        _$failedField = 'nullableValueDoNotUse';
        _nullableValueDoNotUse?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ComplexValue', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

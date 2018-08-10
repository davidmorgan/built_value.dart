// GENERATED CODE - DO NOT MODIFY BY HAND

part of standard_json;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: avoid_returning_this
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first

Serializer<StandardJsonValue> _$standardJsonValueSerializer =
    _$StandardJsonValueSerializer();

class _$StandardJsonValueSerializer
    implements StructuredSerializer<StandardJsonValue> {
  @override
  final Iterable<Type> types = const [StandardJsonValue, _$StandardJsonValue];
  @override
  final String wireName = 'StandardJsonValue';

  @override
  Iterable serialize(Serializers serializers, StandardJsonValue object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'number',
      serializers.serialize(object.number, specifiedType: const FullType(num)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'keyValues',
      serializers.serialize(object.keyValues,
          specifiedType: const FullType(
              BuiltMap, [FullType(String), FullType(JsonObject)])),
      'zoo',
      serializers.serialize(object.zoo,
          specifiedType: const FullType(BuiltList, [FullType(Animal)])),
      'uniqueZoo',
      serializers.serialize(object.uniqueZoo,
          specifiedType: const FullType(BuiltSet, [FullType(Animal)])),
    ];
    if (object.strings != null) {
      result
        ..add('strings')
        ..add(serializers.serialize(object.strings,
            specifiedType: const FullType(BuiltList, [FullType(String)])));
    }

    return result;
  }

  @override
  StandardJsonValue deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = StandardJsonValueBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'number':
          result.number = serializers.deserialize(value,
              specifiedType: const FullType(num)) as num;
          break;
        case 'text':
          result.text = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'keyValues':
          result.keyValues.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltMap, [FullType(String), FullType(JsonObject)]))
              as BuiltMap);
          break;
        case 'zoo':
          result.zoo.replace(serializers.deserialize(value,
                  specifiedType: const FullType(BuiltList, [FullType(Animal)]))
              as BuiltList);
          break;
        case 'uniqueZoo':
          result.uniqueZoo.replace(serializers.deserialize(value,
                  specifiedType: const FullType(BuiltSet, [FullType(Animal)]))
              as BuiltSet);
          break;
        case 'strings':
          result.strings.replace(serializers.deserialize(value,
                  specifiedType: const FullType(BuiltList, [FullType(String)]))
              as BuiltList);
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
  final BuiltMap<String, JsonObject> keyValues;
  @override
  final BuiltList<Animal> zoo;
  @override
  final BuiltSet<Animal> uniqueZoo;
  @override
  final BuiltList<String> strings;

  factory _$StandardJsonValue([void updates(StandardJsonValueBuilder b)]) =>
      (StandardJsonValueBuilder()..update(updates)).build();

  _$StandardJsonValue._(
      {this.number,
      this.text,
      this.keyValues,
      this.zoo,
      this.uniqueZoo,
      this.strings})
      : super._() {
    if (number == null)
      throw BuiltValueNullFieldError('StandardJsonValue', 'number');
    if (text == null)
      throw BuiltValueNullFieldError('StandardJsonValue', 'text');
    if (keyValues == null)
      throw BuiltValueNullFieldError('StandardJsonValue', 'keyValues');
    if (zoo == null) throw BuiltValueNullFieldError('StandardJsonValue', 'zoo');
    if (uniqueZoo == null)
      throw BuiltValueNullFieldError('StandardJsonValue', 'uniqueZoo');
  }

  @override
  StandardJsonValue rebuild(void updates(StandardJsonValueBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardJsonValueBuilder toBuilder() =>
      StandardJsonValueBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! StandardJsonValue) return false;
    return number == other.number &&
        text == other.text &&
        keyValues == other.keyValues &&
        zoo == other.zoo &&
        uniqueZoo == other.uniqueZoo &&
        strings == other.strings;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, number.hashCode), text.hashCode),
                    keyValues.hashCode),
                zoo.hashCode),
            uniqueZoo.hashCode),
        strings.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('StandardJsonValue')
          ..add('number', number)
          ..add('text', text)
          ..add('keyValues', keyValues)
          ..add('zoo', zoo)
          ..add('uniqueZoo', uniqueZoo)
          ..add('strings', strings))
        .toString();
  }
}

class StandardJsonValueBuilder
    implements Builder<StandardJsonValue, StandardJsonValueBuilder> {
  _$StandardJsonValue _$v;

  num _number;
  num get number => _$this._number;
  set number(num number) => _$this._number = number;

  String _text;
  String get text => _$this._text;
  set text(String text) => _$this._text = text;

  MapBuilder<String, JsonObject> _keyValues;
  MapBuilder<String, JsonObject> get keyValues =>
      _$this._keyValues ??= MapBuilder<String, JsonObject>();
  set keyValues(MapBuilder<String, JsonObject> keyValues) =>
      _$this._keyValues = keyValues;

  ListBuilder<Animal> _zoo;
  ListBuilder<Animal> get zoo => _$this._zoo ??= ListBuilder<Animal>();
  set zoo(ListBuilder<Animal> zoo) => _$this._zoo = zoo;

  SetBuilder<Animal> _uniqueZoo;
  SetBuilder<Animal> get uniqueZoo =>
      _$this._uniqueZoo ??= SetBuilder<Animal>();
  set uniqueZoo(SetBuilder<Animal> uniqueZoo) => _$this._uniqueZoo = uniqueZoo;

  ListBuilder<String> _strings;
  ListBuilder<String> get strings => _$this._strings ??= ListBuilder<String>();
  set strings(ListBuilder<String> strings) => _$this._strings = strings;

  StandardJsonValueBuilder();

  StandardJsonValueBuilder get _$this {
    if (_$v != null) {
      _number = _$v.number;
      _text = _$v.text;
      _keyValues = _$v.keyValues?.toBuilder();
      _zoo = _$v.zoo?.toBuilder();
      _uniqueZoo = _$v.uniqueZoo?.toBuilder();
      _strings = _$v.strings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandardJsonValue other) {
    if (other == null) throw ArgumentError.notNull('other');
    _$v = other as _$StandardJsonValue;
  }

  @override
  void update(void updates(StandardJsonValueBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$StandardJsonValue build() {
    _$StandardJsonValue _$result;
    try {
      _$result = _$v ??
          _$StandardJsonValue._(
              number: number,
              text: text,
              keyValues: keyValues.build(),
              zoo: zoo.build(),
              uniqueZoo: uniqueZoo.build(),
              strings: _strings?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'keyValues';
        keyValues.build();
        _$failedField = 'zoo';
        zoo.build();
        _$failedField = 'uniqueZoo';
        uniqueZoo.build();
        _$failedField = 'strings';
        _strings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            'StandardJsonValue', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

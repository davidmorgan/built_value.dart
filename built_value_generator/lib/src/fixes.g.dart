// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixes.dart';

// **************************************************************************
// Generator: BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_returning_this
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first

class _$SourceSnippet extends SourceSnippet {
  @override
  final int position;
  @override
  final String source;

  factory _$SourceSnippet([void updates(SourceSnippetBuilder b)]) =>
      (new SourceSnippetBuilder()..update(updates)).build();

  _$SourceSnippet._({this.position, this.source}) : super._() {
    if (position == null)
      throw new BuiltValueNullFieldError('SourceSnippet', 'position');
    if (source == null)
      throw new BuiltValueNullFieldError('SourceSnippet', 'source');
  }

  @override
  SourceSnippet rebuild(void updates(SourceSnippetBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  SourceSnippetBuilder toBuilder() => new SourceSnippetBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! SourceSnippet) return false;
    return position == other.position && source == other.source;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, position.hashCode), source.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SourceSnippet')
          ..add('position', position)
          ..add('source', source))
        .toString();
  }
}

class SourceSnippetBuilder
    implements Builder<SourceSnippet, SourceSnippetBuilder> {
  _$SourceSnippet _$v;

  int _position;
  int get position => _$this._position;
  set position(int position) => _$this._position = position;

  String _source;
  String get source => _$this._source;
  set source(String source) => _$this._source = source;

  SourceSnippetBuilder();

  SourceSnippetBuilder get _$this {
    if (_$v != null) {
      _position = _$v.position;
      _source = _$v.source;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SourceSnippet other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$SourceSnippet;
  }

  @override
  void update(void updates(SourceSnippetBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$SourceSnippet build() {
    final _$result =
        _$v ?? new _$SourceSnippet._(position: position, source: source);
    replace(_$result);
    return _$result;
  }
}

class _$GeneratorError extends GeneratorError {
  @override
  final String message;
  @override
  final int position;
  @override
  final int length;
  @override
  final String fix;

  factory _$GeneratorError([void updates(GeneratorErrorBuilder b)]) =>
      (new GeneratorErrorBuilder()..update(updates)).build();

  _$GeneratorError._({this.message, this.position, this.length, this.fix})
      : super._() {
    if (message == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'message');
    if (position == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'position');
    if (length == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'length');
  }

  @override
  GeneratorError rebuild(void updates(GeneratorErrorBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  GeneratorErrorBuilder toBuilder() =>
      new GeneratorErrorBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! GeneratorError) return false;
    return message == other.message &&
        position == other.position &&
        length == other.length &&
        fix == other.fix;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, message.hashCode), position.hashCode), length.hashCode),
        fix.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('GeneratorError')
          ..add('message', message)
          ..add('position', position)
          ..add('length', length)
          ..add('fix', fix))
        .toString();
  }
}

class GeneratorErrorBuilder
    implements Builder<GeneratorError, GeneratorErrorBuilder> {
  _$GeneratorError _$v;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  int _position;
  int get position => _$this._position;
  set position(int position) => _$this._position = position;

  int _length;
  int get length => _$this._length;
  set length(int length) => _$this._length = length;

  String _fix;
  String get fix => _$this._fix;
  set fix(String fix) => _$this._fix = fix;

  GeneratorErrorBuilder();

  GeneratorErrorBuilder get _$this {
    if (_$v != null) {
      _message = _$v.message;
      _position = _$v.position;
      _length = _$v.length;
      _fix = _$v.fix;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeneratorError other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$GeneratorError;
  }

  @override
  void update(void updates(GeneratorErrorBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$GeneratorError build() {
    final _$result = _$v ??
        new _$GeneratorError._(
            message: message, position: position, length: length, fix: fix);
    replace(_$result);
    return _$result;
  }
}

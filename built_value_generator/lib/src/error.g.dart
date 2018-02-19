// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

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

class _$GeneratorError extends GeneratorError {
  @override
  final String message;
  @override
  final int fixAt;
  @override
  final int fixLength;
  @override
  final String fix;

  factory _$GeneratorError([void updates(GeneratorErrorBuilder b)]) =>
      (new GeneratorErrorBuilder()..update(updates)).build();

  _$GeneratorError._({this.message, this.fixAt, this.fixLength, this.fix})
      : super._() {
    if (message == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'message');
    if (fixAt == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'fixAt');
    if (fixLength == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'fixLength');
    if (fix == null)
      throw new BuiltValueNullFieldError('GeneratorError', 'fix');
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
        fixAt == other.fixAt &&
        fixLength == other.fixLength &&
        fix == other.fix;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, message.hashCode), fixAt.hashCode), fixLength.hashCode),
        fix.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('GeneratorError')
          ..add('message', message)
          ..add('fixAt', fixAt)
          ..add('fixLength', fixLength)
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

  int _fixAt;
  int get fixAt => _$this._fixAt;
  set fixAt(int fixAt) => _$this._fixAt = fixAt;

  int _fixLength;
  int get fixLength => _$this._fixLength;
  set fixLength(int fixLength) => _$this._fixLength = fixLength;

  String _fix;
  String get fix => _$this._fix;
  set fix(String fix) => _$this._fix = fix;

  GeneratorErrorBuilder();

  GeneratorErrorBuilder get _$this {
    if (_$v != null) {
      _message = _$v.message;
      _fixAt = _$v.fixAt;
      _fixLength = _$v.fixLength;
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
            message: message, fixAt: fixAt, fixLength: fixLength, fix: fix);
    replace(_$result);
    return _$result;
  }
}

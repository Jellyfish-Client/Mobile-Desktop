// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_keyword_id_get500_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KeywordKeywordIdGet500Response extends KeywordKeywordIdGet500Response {
  @override
  final String? message;

  factory _$KeywordKeywordIdGet500Response(
          [void Function(KeywordKeywordIdGet500ResponseBuilder)? updates]) =>
      (KeywordKeywordIdGet500ResponseBuilder()..update(updates))._build();

  _$KeywordKeywordIdGet500Response._({this.message}) : super._();
  @override
  KeywordKeywordIdGet500Response rebuild(
          void Function(KeywordKeywordIdGet500ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KeywordKeywordIdGet500ResponseBuilder toBuilder() =>
      KeywordKeywordIdGet500ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KeywordKeywordIdGet500Response && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KeywordKeywordIdGet500Response')
          ..add('message', message))
        .toString();
  }
}

class KeywordKeywordIdGet500ResponseBuilder
    implements
        Builder<KeywordKeywordIdGet500Response,
            KeywordKeywordIdGet500ResponseBuilder> {
  _$KeywordKeywordIdGet500Response? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  KeywordKeywordIdGet500ResponseBuilder() {
    KeywordKeywordIdGet500Response._defaults(this);
  }

  KeywordKeywordIdGet500ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KeywordKeywordIdGet500Response other) {
    _$v = other as _$KeywordKeywordIdGet500Response;
  }

  @override
  void update(void Function(KeywordKeywordIdGet500ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KeywordKeywordIdGet500Response build() => _build();

  _$KeywordKeywordIdGet500Response _build() {
    final _$result = _$v ??
        _$KeywordKeywordIdGet500Response._(
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

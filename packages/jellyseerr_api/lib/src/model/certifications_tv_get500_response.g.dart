// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certifications_tv_get500_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CertificationsTvGet500Response extends CertificationsTvGet500Response {
  @override
  final num? status;
  @override
  final String? message;

  factory _$CertificationsTvGet500Response(
          [void Function(CertificationsTvGet500ResponseBuilder)? updates]) =>
      (CertificationsTvGet500ResponseBuilder()..update(updates))._build();

  _$CertificationsTvGet500Response._({this.status, this.message}) : super._();
  @override
  CertificationsTvGet500Response rebuild(
          void Function(CertificationsTvGet500ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CertificationsTvGet500ResponseBuilder toBuilder() =>
      CertificationsTvGet500ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CertificationsTvGet500Response &&
        status == other.status &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CertificationsTvGet500Response')
          ..add('status', status)
          ..add('message', message))
        .toString();
  }
}

class CertificationsTvGet500ResponseBuilder
    implements
        Builder<CertificationsTvGet500Response,
            CertificationsTvGet500ResponseBuilder> {
  _$CertificationsTvGet500Response? _$v;

  num? _status;
  num? get status => _$this._status;
  set status(num? status) => _$this._status = status;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  CertificationsTvGet500ResponseBuilder() {
    CertificationsTvGet500Response._defaults(this);
  }

  CertificationsTvGet500ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CertificationsTvGet500Response other) {
    _$v = other as _$CertificationsTvGet500Response;
  }

  @override
  void update(void Function(CertificationsTvGet500ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CertificationsTvGet500Response build() => _build();

  _$CertificationsTvGet500Response _build() {
    final _$result = _$v ??
        _$CertificationsTvGet500Response._(
          status: status,
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

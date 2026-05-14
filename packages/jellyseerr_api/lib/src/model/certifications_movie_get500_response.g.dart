// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certifications_movie_get500_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CertificationsMovieGet500Response
    extends CertificationsMovieGet500Response {
  @override
  final num? status;
  @override
  final String? message;

  factory _$CertificationsMovieGet500Response(
          [void Function(CertificationsMovieGet500ResponseBuilder)? updates]) =>
      (CertificationsMovieGet500ResponseBuilder()..update(updates))._build();

  _$CertificationsMovieGet500Response._({this.status, this.message})
      : super._();
  @override
  CertificationsMovieGet500Response rebuild(
          void Function(CertificationsMovieGet500ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CertificationsMovieGet500ResponseBuilder toBuilder() =>
      CertificationsMovieGet500ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CertificationsMovieGet500Response &&
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
    return (newBuiltValueToStringHelper(r'CertificationsMovieGet500Response')
          ..add('status', status)
          ..add('message', message))
        .toString();
  }
}

class CertificationsMovieGet500ResponseBuilder
    implements
        Builder<CertificationsMovieGet500Response,
            CertificationsMovieGet500ResponseBuilder> {
  _$CertificationsMovieGet500Response? _$v;

  num? _status;
  num? get status => _$this._status;
  set status(num? status) => _$this._status = status;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  CertificationsMovieGet500ResponseBuilder() {
    CertificationsMovieGet500Response._defaults(this);
  }

  CertificationsMovieGet500ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CertificationsMovieGet500Response other) {
    _$v = other as _$CertificationsMovieGet500Response;
  }

  @override
  void update(
      void Function(CertificationsMovieGet500ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CertificationsMovieGet500Response build() => _build();

  _$CertificationsMovieGet500Response _build() {
    final _$result = _$v ??
        _$CertificationsMovieGet500Response._(
          status: status,
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

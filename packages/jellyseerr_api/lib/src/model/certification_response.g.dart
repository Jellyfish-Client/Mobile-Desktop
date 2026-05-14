// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certification_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CertificationResponse extends CertificationResponse {
  @override
  final BuiltMap<String, BuiltList<Certification>>? certifications;

  factory _$CertificationResponse(
          [void Function(CertificationResponseBuilder)? updates]) =>
      (CertificationResponseBuilder()..update(updates))._build();

  _$CertificationResponse._({this.certifications}) : super._();
  @override
  CertificationResponse rebuild(
          void Function(CertificationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CertificationResponseBuilder toBuilder() =>
      CertificationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CertificationResponse &&
        certifications == other.certifications;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certifications.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CertificationResponse')
          ..add('certifications', certifications))
        .toString();
  }
}

class CertificationResponseBuilder
    implements Builder<CertificationResponse, CertificationResponseBuilder> {
  _$CertificationResponse? _$v;

  MapBuilder<String, BuiltList<Certification>>? _certifications;
  MapBuilder<String, BuiltList<Certification>> get certifications =>
      _$this._certifications ??= MapBuilder<String, BuiltList<Certification>>();
  set certifications(
          MapBuilder<String, BuiltList<Certification>>? certifications) =>
      _$this._certifications = certifications;

  CertificationResponseBuilder() {
    CertificationResponse._defaults(this);
  }

  CertificationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _certifications = $v.certifications?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CertificationResponse other) {
    _$v = other as _$CertificationResponse;
  }

  @override
  void update(void Function(CertificationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CertificationResponse build() => _build();

  _$CertificationResponse _build() {
    _$CertificationResponse _$result;
    try {
      _$result = _$v ??
          _$CertificationResponse._(
            certifications: _certifications?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'certifications';
        _certifications?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CertificationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

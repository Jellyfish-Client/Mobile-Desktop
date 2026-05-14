// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Certification extends Certification {
  @override
  final String certification;
  @override
  final String? meaning;
  @override
  final num? order;

  factory _$Certification([void Function(CertificationBuilder)? updates]) =>
      (CertificationBuilder()..update(updates))._build();

  _$Certification._({required this.certification, this.meaning, this.order})
      : super._();
  @override
  Certification rebuild(void Function(CertificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CertificationBuilder toBuilder() => CertificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Certification &&
        certification == other.certification &&
        meaning == other.meaning &&
        order == other.order;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certification.hashCode);
    _$hash = $jc(_$hash, meaning.hashCode);
    _$hash = $jc(_$hash, order.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Certification')
          ..add('certification', certification)
          ..add('meaning', meaning)
          ..add('order', order))
        .toString();
  }
}

class CertificationBuilder
    implements Builder<Certification, CertificationBuilder> {
  _$Certification? _$v;

  String? _certification;
  String? get certification => _$this._certification;
  set certification(String? certification) =>
      _$this._certification = certification;

  String? _meaning;
  String? get meaning => _$this._meaning;
  set meaning(String? meaning) => _$this._meaning = meaning;

  num? _order;
  num? get order => _$this._order;
  set order(num? order) => _$this._order = order;

  CertificationBuilder() {
    Certification._defaults(this);
  }

  CertificationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _certification = $v.certification;
      _meaning = $v.meaning;
      _order = $v.order;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Certification other) {
    _$v = other as _$Certification;
  }

  @override
  void update(void Function(CertificationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Certification build() => _build();

  _$Certification _build() {
    final _$result = _$v ??
        _$Certification._(
          certification: BuiltValueNullFieldError.checkNotNull(
              certification, r'Certification', 'certification'),
          meaning: meaning,
          order: order,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

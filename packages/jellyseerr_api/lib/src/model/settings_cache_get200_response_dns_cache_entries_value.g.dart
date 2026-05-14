// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cache_get200_response_dns_cache_entries_value.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsCacheGet200ResponseDnsCacheEntriesValue
    extends SettingsCacheGet200ResponseDnsCacheEntriesValue {
  @override
  final SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses? addresses;
  @override
  final String? activeAddress;
  @override
  final num? family;
  @override
  final num? age;
  @override
  final num? ttl;
  @override
  final num? networkErrors;
  @override
  final num? hits;
  @override
  final num? misses;

  factory _$SettingsCacheGet200ResponseDnsCacheEntriesValue(
          [void Function(
                  SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder)?
              updates]) =>
      (SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder()
            ..update(updates))
          ._build();

  _$SettingsCacheGet200ResponseDnsCacheEntriesValue._(
      {this.addresses,
      this.activeAddress,
      this.family,
      this.age,
      this.ttl,
      this.networkErrors,
      this.hits,
      this.misses})
      : super._();
  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValue rebuild(
          void Function(SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder toBuilder() =>
      SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsCacheGet200ResponseDnsCacheEntriesValue &&
        addresses == other.addresses &&
        activeAddress == other.activeAddress &&
        family == other.family &&
        age == other.age &&
        ttl == other.ttl &&
        networkErrors == other.networkErrors &&
        hits == other.hits &&
        misses == other.misses;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, addresses.hashCode);
    _$hash = $jc(_$hash, activeAddress.hashCode);
    _$hash = $jc(_$hash, family.hashCode);
    _$hash = $jc(_$hash, age.hashCode);
    _$hash = $jc(_$hash, ttl.hashCode);
    _$hash = $jc(_$hash, networkErrors.hashCode);
    _$hash = $jc(_$hash, hits.hashCode);
    _$hash = $jc(_$hash, misses.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SettingsCacheGet200ResponseDnsCacheEntriesValue')
          ..add('addresses', addresses)
          ..add('activeAddress', activeAddress)
          ..add('family', family)
          ..add('age', age)
          ..add('ttl', ttl)
          ..add('networkErrors', networkErrors)
          ..add('hits', hits)
          ..add('misses', misses))
        .toString();
  }
}

class SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder
    implements
        Builder<SettingsCacheGet200ResponseDnsCacheEntriesValue,
            SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder> {
  _$SettingsCacheGet200ResponseDnsCacheEntriesValue? _$v;

  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder? _addresses;
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder
      get addresses => _$this._addresses ??=
          SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder();
  set addresses(
          SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder?
              addresses) =>
      _$this._addresses = addresses;

  String? _activeAddress;
  String? get activeAddress => _$this._activeAddress;
  set activeAddress(String? activeAddress) =>
      _$this._activeAddress = activeAddress;

  num? _family;
  num? get family => _$this._family;
  set family(num? family) => _$this._family = family;

  num? _age;
  num? get age => _$this._age;
  set age(num? age) => _$this._age = age;

  num? _ttl;
  num? get ttl => _$this._ttl;
  set ttl(num? ttl) => _$this._ttl = ttl;

  num? _networkErrors;
  num? get networkErrors => _$this._networkErrors;
  set networkErrors(num? networkErrors) =>
      _$this._networkErrors = networkErrors;

  num? _hits;
  num? get hits => _$this._hits;
  set hits(num? hits) => _$this._hits = hits;

  num? _misses;
  num? get misses => _$this._misses;
  set misses(num? misses) => _$this._misses = misses;

  SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder() {
    SettingsCacheGet200ResponseDnsCacheEntriesValue._defaults(this);
  }

  SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _addresses = $v.addresses?.toBuilder();
      _activeAddress = $v.activeAddress;
      _family = $v.family;
      _age = $v.age;
      _ttl = $v.ttl;
      _networkErrors = $v.networkErrors;
      _hits = $v.hits;
      _misses = $v.misses;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsCacheGet200ResponseDnsCacheEntriesValue other) {
    _$v = other as _$SettingsCacheGet200ResponseDnsCacheEntriesValue;
  }

  @override
  void update(
      void Function(SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValue build() => _build();

  _$SettingsCacheGet200ResponseDnsCacheEntriesValue _build() {
    _$SettingsCacheGet200ResponseDnsCacheEntriesValue _$result;
    try {
      _$result = _$v ??
          _$SettingsCacheGet200ResponseDnsCacheEntriesValue._(
            addresses: _addresses?.build(),
            activeAddress: activeAddress,
            family: family,
            age: age,
            ttl: ttl,
            networkErrors: networkErrors,
            hits: hits,
            misses: misses,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'addresses';
        _addresses?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SettingsCacheGet200ResponseDnsCacheEntriesValue',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

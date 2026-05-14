// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cache_get200_response_dns_cache_entries_value_addresses.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses
    extends SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses {
  @override
  final num? ipv4;
  @override
  final num? ipv6;

  factory _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses(
          [void Function(
                  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder)?
              updates]) =>
      (SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder()
            ..update(updates))
          ._build();

  _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses._(
      {this.ipv4, this.ipv6})
      : super._();
  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses rebuild(
          void Function(
                  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder toBuilder() =>
      SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses &&
        ipv4 == other.ipv4 &&
        ipv6 == other.ipv6;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ipv4.hashCode);
    _$hash = $jc(_$hash, ipv6.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses')
          ..add('ipv4', ipv4)
          ..add('ipv6', ipv6))
        .toString();
  }
}

class SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder
    implements
        Builder<SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses,
            SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder> {
  _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses? _$v;

  num? _ipv4;
  num? get ipv4 => _$this._ipv4;
  set ipv4(num? ipv4) => _$this._ipv4 = ipv4;

  num? _ipv6;
  num? get ipv6 => _$this._ipv6;
  set ipv6(num? ipv6) => _$this._ipv6 = ipv6;

  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder() {
    SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses._defaults(this);
  }

  SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ipv4 = $v.ipv4;
      _ipv6 = $v.ipv6;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses other) {
    _$v = other as _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses;
  }

  @override
  void update(
      void Function(
              SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses build() => _build();

  _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses _build() {
    final _$result = _$v ??
        _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses._(
          ipv4: ipv4,
          ipv6: ipv6,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

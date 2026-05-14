// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_settings_dns_cache.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NetworkSettingsDnsCache extends NetworkSettingsDnsCache {
  @override
  final bool? enabled;
  @override
  final num? forceMinTtl;
  @override
  final num? forceMaxTtl;

  factory _$NetworkSettingsDnsCache(
          [void Function(NetworkSettingsDnsCacheBuilder)? updates]) =>
      (NetworkSettingsDnsCacheBuilder()..update(updates))._build();

  _$NetworkSettingsDnsCache._(
      {this.enabled, this.forceMinTtl, this.forceMaxTtl})
      : super._();
  @override
  NetworkSettingsDnsCache rebuild(
          void Function(NetworkSettingsDnsCacheBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NetworkSettingsDnsCacheBuilder toBuilder() =>
      NetworkSettingsDnsCacheBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NetworkSettingsDnsCache &&
        enabled == other.enabled &&
        forceMinTtl == other.forceMinTtl &&
        forceMaxTtl == other.forceMaxTtl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, forceMinTtl.hashCode);
    _$hash = $jc(_$hash, forceMaxTtl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NetworkSettingsDnsCache')
          ..add('enabled', enabled)
          ..add('forceMinTtl', forceMinTtl)
          ..add('forceMaxTtl', forceMaxTtl))
        .toString();
  }
}

class NetworkSettingsDnsCacheBuilder
    implements
        Builder<NetworkSettingsDnsCache, NetworkSettingsDnsCacheBuilder> {
  _$NetworkSettingsDnsCache? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  num? _forceMinTtl;
  num? get forceMinTtl => _$this._forceMinTtl;
  set forceMinTtl(num? forceMinTtl) => _$this._forceMinTtl = forceMinTtl;

  num? _forceMaxTtl;
  num? get forceMaxTtl => _$this._forceMaxTtl;
  set forceMaxTtl(num? forceMaxTtl) => _$this._forceMaxTtl = forceMaxTtl;

  NetworkSettingsDnsCacheBuilder() {
    NetworkSettingsDnsCache._defaults(this);
  }

  NetworkSettingsDnsCacheBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _forceMinTtl = $v.forceMinTtl;
      _forceMaxTtl = $v.forceMaxTtl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NetworkSettingsDnsCache other) {
    _$v = other as _$NetworkSettingsDnsCache;
  }

  @override
  void update(void Function(NetworkSettingsDnsCacheBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NetworkSettingsDnsCache build() => _build();

  _$NetworkSettingsDnsCache _build() {
    final _$result = _$v ??
        _$NetworkSettingsDnsCache._(
          enabled: enabled,
          forceMinTtl: forceMinTtl,
          forceMaxTtl: forceMaxTtl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

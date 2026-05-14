// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NetworkSettings extends NetworkSettings {
  @override
  final bool? csrfProtection;
  @override
  final bool? forceIpv4First;
  @override
  final bool? trustProxy;
  @override
  final NetworkSettingsProxy? proxy;
  @override
  final NetworkSettingsDnsCache? dnsCache;

  factory _$NetworkSettings([void Function(NetworkSettingsBuilder)? updates]) =>
      (NetworkSettingsBuilder()..update(updates))._build();

  _$NetworkSettings._(
      {this.csrfProtection,
      this.forceIpv4First,
      this.trustProxy,
      this.proxy,
      this.dnsCache})
      : super._();
  @override
  NetworkSettings rebuild(void Function(NetworkSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NetworkSettingsBuilder toBuilder() => NetworkSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NetworkSettings &&
        csrfProtection == other.csrfProtection &&
        forceIpv4First == other.forceIpv4First &&
        trustProxy == other.trustProxy &&
        proxy == other.proxy &&
        dnsCache == other.dnsCache;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, csrfProtection.hashCode);
    _$hash = $jc(_$hash, forceIpv4First.hashCode);
    _$hash = $jc(_$hash, trustProxy.hashCode);
    _$hash = $jc(_$hash, proxy.hashCode);
    _$hash = $jc(_$hash, dnsCache.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NetworkSettings')
          ..add('csrfProtection', csrfProtection)
          ..add('forceIpv4First', forceIpv4First)
          ..add('trustProxy', trustProxy)
          ..add('proxy', proxy)
          ..add('dnsCache', dnsCache))
        .toString();
  }
}

class NetworkSettingsBuilder
    implements Builder<NetworkSettings, NetworkSettingsBuilder> {
  _$NetworkSettings? _$v;

  bool? _csrfProtection;
  bool? get csrfProtection => _$this._csrfProtection;
  set csrfProtection(bool? csrfProtection) =>
      _$this._csrfProtection = csrfProtection;

  bool? _forceIpv4First;
  bool? get forceIpv4First => _$this._forceIpv4First;
  set forceIpv4First(bool? forceIpv4First) =>
      _$this._forceIpv4First = forceIpv4First;

  bool? _trustProxy;
  bool? get trustProxy => _$this._trustProxy;
  set trustProxy(bool? trustProxy) => _$this._trustProxy = trustProxy;

  NetworkSettingsProxyBuilder? _proxy;
  NetworkSettingsProxyBuilder get proxy =>
      _$this._proxy ??= NetworkSettingsProxyBuilder();
  set proxy(NetworkSettingsProxyBuilder? proxy) => _$this._proxy = proxy;

  NetworkSettingsDnsCacheBuilder? _dnsCache;
  NetworkSettingsDnsCacheBuilder get dnsCache =>
      _$this._dnsCache ??= NetworkSettingsDnsCacheBuilder();
  set dnsCache(NetworkSettingsDnsCacheBuilder? dnsCache) =>
      _$this._dnsCache = dnsCache;

  NetworkSettingsBuilder() {
    NetworkSettings._defaults(this);
  }

  NetworkSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _csrfProtection = $v.csrfProtection;
      _forceIpv4First = $v.forceIpv4First;
      _trustProxy = $v.trustProxy;
      _proxy = $v.proxy?.toBuilder();
      _dnsCache = $v.dnsCache?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NetworkSettings other) {
    _$v = other as _$NetworkSettings;
  }

  @override
  void update(void Function(NetworkSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NetworkSettings build() => _build();

  _$NetworkSettings _build() {
    _$NetworkSettings _$result;
    try {
      _$result = _$v ??
          _$NetworkSettings._(
            csrfProtection: csrfProtection,
            forceIpv4First: forceIpv4First,
            trustProxy: trustProxy,
            proxy: _proxy?.build(),
            dnsCache: _dnsCache?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'proxy';
        _proxy?.build();
        _$failedField = 'dnsCache';
        _dnsCache?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NetworkSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

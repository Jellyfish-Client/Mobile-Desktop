// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_settings_proxy.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NetworkSettingsProxy extends NetworkSettingsProxy {
  @override
  final bool? enabled;
  @override
  final String? hostname;
  @override
  final num? port;
  @override
  final bool? useSsl;
  @override
  final String? user;
  @override
  final String? password;
  @override
  final String? bypassFilter;
  @override
  final bool? bypassLocalAddresses;

  factory _$NetworkSettingsProxy(
          [void Function(NetworkSettingsProxyBuilder)? updates]) =>
      (NetworkSettingsProxyBuilder()..update(updates))._build();

  _$NetworkSettingsProxy._(
      {this.enabled,
      this.hostname,
      this.port,
      this.useSsl,
      this.user,
      this.password,
      this.bypassFilter,
      this.bypassLocalAddresses})
      : super._();
  @override
  NetworkSettingsProxy rebuild(
          void Function(NetworkSettingsProxyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NetworkSettingsProxyBuilder toBuilder() =>
      NetworkSettingsProxyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NetworkSettingsProxy &&
        enabled == other.enabled &&
        hostname == other.hostname &&
        port == other.port &&
        useSsl == other.useSsl &&
        user == other.user &&
        password == other.password &&
        bypassFilter == other.bypassFilter &&
        bypassLocalAddresses == other.bypassLocalAddresses;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, hostname.hashCode);
    _$hash = $jc(_$hash, port.hashCode);
    _$hash = $jc(_$hash, useSsl.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, bypassFilter.hashCode);
    _$hash = $jc(_$hash, bypassLocalAddresses.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NetworkSettingsProxy')
          ..add('enabled', enabled)
          ..add('hostname', hostname)
          ..add('port', port)
          ..add('useSsl', useSsl)
          ..add('user', user)
          ..add('password', password)
          ..add('bypassFilter', bypassFilter)
          ..add('bypassLocalAddresses', bypassLocalAddresses))
        .toString();
  }
}

class NetworkSettingsProxyBuilder
    implements Builder<NetworkSettingsProxy, NetworkSettingsProxyBuilder> {
  _$NetworkSettingsProxy? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  String? _hostname;
  String? get hostname => _$this._hostname;
  set hostname(String? hostname) => _$this._hostname = hostname;

  num? _port;
  num? get port => _$this._port;
  set port(num? port) => _$this._port = port;

  bool? _useSsl;
  bool? get useSsl => _$this._useSsl;
  set useSsl(bool? useSsl) => _$this._useSsl = useSsl;

  String? _user;
  String? get user => _$this._user;
  set user(String? user) => _$this._user = user;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _bypassFilter;
  String? get bypassFilter => _$this._bypassFilter;
  set bypassFilter(String? bypassFilter) => _$this._bypassFilter = bypassFilter;

  bool? _bypassLocalAddresses;
  bool? get bypassLocalAddresses => _$this._bypassLocalAddresses;
  set bypassLocalAddresses(bool? bypassLocalAddresses) =>
      _$this._bypassLocalAddresses = bypassLocalAddresses;

  NetworkSettingsProxyBuilder() {
    NetworkSettingsProxy._defaults(this);
  }

  NetworkSettingsProxyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _hostname = $v.hostname;
      _port = $v.port;
      _useSsl = $v.useSsl;
      _user = $v.user;
      _password = $v.password;
      _bypassFilter = $v.bypassFilter;
      _bypassLocalAddresses = $v.bypassLocalAddresses;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NetworkSettingsProxy other) {
    _$v = other as _$NetworkSettingsProxy;
  }

  @override
  void update(void Function(NetworkSettingsProxyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NetworkSettingsProxy build() => _build();

  _$NetworkSettingsProxy _build() {
    final _$result = _$v ??
        _$NetworkSettingsProxy._(
          enabled: enabled,
          hostname: hostname,
          port: port,
          useSsl: useSsl,
          user: user,
          password: password,
          bypassFilter: bypassFilter,
          bypassLocalAddresses: bypassLocalAddresses,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

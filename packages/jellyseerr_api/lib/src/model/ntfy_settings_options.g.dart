// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ntfy_settings_options.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NtfySettingsOptions extends NtfySettingsOptions {
  @override
  final String? url;
  @override
  final String? topic;
  @override
  final bool? authMethodUsernamePassword;
  @override
  final String? username;
  @override
  final String? password;
  @override
  final bool? authMethodToken;
  @override
  final String? token;

  factory _$NtfySettingsOptions(
          [void Function(NtfySettingsOptionsBuilder)? updates]) =>
      (NtfySettingsOptionsBuilder()..update(updates))._build();

  _$NtfySettingsOptions._(
      {this.url,
      this.topic,
      this.authMethodUsernamePassword,
      this.username,
      this.password,
      this.authMethodToken,
      this.token})
      : super._();
  @override
  NtfySettingsOptions rebuild(
          void Function(NtfySettingsOptionsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NtfySettingsOptionsBuilder toBuilder() =>
      NtfySettingsOptionsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NtfySettingsOptions &&
        url == other.url &&
        topic == other.topic &&
        authMethodUsernamePassword == other.authMethodUsernamePassword &&
        username == other.username &&
        password == other.password &&
        authMethodToken == other.authMethodToken &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, topic.hashCode);
    _$hash = $jc(_$hash, authMethodUsernamePassword.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, authMethodToken.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NtfySettingsOptions')
          ..add('url', url)
          ..add('topic', topic)
          ..add('authMethodUsernamePassword', authMethodUsernamePassword)
          ..add('username', username)
          ..add('password', password)
          ..add('authMethodToken', authMethodToken)
          ..add('token', token))
        .toString();
  }
}

class NtfySettingsOptionsBuilder
    implements Builder<NtfySettingsOptions, NtfySettingsOptionsBuilder> {
  _$NtfySettingsOptions? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _topic;
  String? get topic => _$this._topic;
  set topic(String? topic) => _$this._topic = topic;

  bool? _authMethodUsernamePassword;
  bool? get authMethodUsernamePassword => _$this._authMethodUsernamePassword;
  set authMethodUsernamePassword(bool? authMethodUsernamePassword) =>
      _$this._authMethodUsernamePassword = authMethodUsernamePassword;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  bool? _authMethodToken;
  bool? get authMethodToken => _$this._authMethodToken;
  set authMethodToken(bool? authMethodToken) =>
      _$this._authMethodToken = authMethodToken;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  NtfySettingsOptionsBuilder() {
    NtfySettingsOptions._defaults(this);
  }

  NtfySettingsOptionsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _topic = $v.topic;
      _authMethodUsernamePassword = $v.authMethodUsernamePassword;
      _username = $v.username;
      _password = $v.password;
      _authMethodToken = $v.authMethodToken;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NtfySettingsOptions other) {
    _$v = other as _$NtfySettingsOptions;
  }

  @override
  void update(void Function(NtfySettingsOptionsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NtfySettingsOptions build() => _build();

  _$NtfySettingsOptions _build() {
    final _$result = _$v ??
        _$NtfySettingsOptions._(
          url: url,
          topic: topic,
          authMethodUsernamePassword: authMethodUsernamePassword,
          username: username,
          password: password,
          authMethodToken: authMethodToken,
          token: token,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

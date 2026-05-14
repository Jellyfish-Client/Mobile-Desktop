// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_jellyfin_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthJellyfinPostRequest extends AuthJellyfinPostRequest {
  @override
  final String username;
  @override
  final String password;
  @override
  final String? hostname;
  @override
  final String? email;
  @override
  final num? serverType;

  factory _$AuthJellyfinPostRequest(
          [void Function(AuthJellyfinPostRequestBuilder)? updates]) =>
      (AuthJellyfinPostRequestBuilder()..update(updates))._build();

  _$AuthJellyfinPostRequest._(
      {required this.username,
      required this.password,
      this.hostname,
      this.email,
      this.serverType})
      : super._();
  @override
  AuthJellyfinPostRequest rebuild(
          void Function(AuthJellyfinPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthJellyfinPostRequestBuilder toBuilder() =>
      AuthJellyfinPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthJellyfinPostRequest &&
        username == other.username &&
        password == other.password &&
        hostname == other.hostname &&
        email == other.email &&
        serverType == other.serverType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, hostname.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, serverType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthJellyfinPostRequest')
          ..add('username', username)
          ..add('password', password)
          ..add('hostname', hostname)
          ..add('email', email)
          ..add('serverType', serverType))
        .toString();
  }
}

class AuthJellyfinPostRequestBuilder
    implements
        Builder<AuthJellyfinPostRequest, AuthJellyfinPostRequestBuilder> {
  _$AuthJellyfinPostRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _hostname;
  String? get hostname => _$this._hostname;
  set hostname(String? hostname) => _$this._hostname = hostname;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  num? _serverType;
  num? get serverType => _$this._serverType;
  set serverType(num? serverType) => _$this._serverType = serverType;

  AuthJellyfinPostRequestBuilder() {
    AuthJellyfinPostRequest._defaults(this);
  }

  AuthJellyfinPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _password = $v.password;
      _hostname = $v.hostname;
      _email = $v.email;
      _serverType = $v.serverType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthJellyfinPostRequest other) {
    _$v = other as _$AuthJellyfinPostRequest;
  }

  @override
  void update(void Function(AuthJellyfinPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthJellyfinPostRequest build() => _build();

  _$AuthJellyfinPostRequest _build() {
    final _$result = _$v ??
        _$AuthJellyfinPostRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'AuthJellyfinPostRequest', 'username'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AuthJellyfinPostRequest', 'password'),
          hostname: hostname,
          email: email,
          serverType: serverType,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

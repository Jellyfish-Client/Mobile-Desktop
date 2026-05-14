// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_user_id_settings_linked_accounts_jellyfin_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest
    extends UserUserIdSettingsLinkedAccountsJellyfinPostRequest {
  @override
  final String? username;
  @override
  final String? password;

  factory _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest(
          [void Function(
                  UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder)?
              updates]) =>
      (UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder()
            ..update(updates))
          ._build();

  _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest._(
      {this.username, this.password})
      : super._();
  @override
  UserUserIdSettingsLinkedAccountsJellyfinPostRequest rebuild(
          void Function(
                  UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder toBuilder() =>
      UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserUserIdSettingsLinkedAccountsJellyfinPostRequest &&
        username == other.username &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'UserUserIdSettingsLinkedAccountsJellyfinPostRequest')
          ..add('username', username)
          ..add('password', password))
        .toString();
  }
}

class UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder
    implements
        Builder<UserUserIdSettingsLinkedAccountsJellyfinPostRequest,
            UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder> {
  _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder() {
    UserUserIdSettingsLinkedAccountsJellyfinPostRequest._defaults(this);
  }

  UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserUserIdSettingsLinkedAccountsJellyfinPostRequest other) {
    _$v = other as _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest;
  }

  @override
  void update(
      void Function(UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  UserUserIdSettingsLinkedAccountsJellyfinPostRequest build() => _build();

  _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest _build() {
    final _$result = _$v ??
        _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest._(
          username: username,
          password: password,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

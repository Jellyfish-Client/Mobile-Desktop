// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_jellyfin_users_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsJellyfinUsersGet200ResponseInner
    extends SettingsJellyfinUsersGet200ResponseInner {
  @override
  final String? username;
  @override
  final String? id;
  @override
  final String? thumb;
  @override
  final String? email;

  factory _$SettingsJellyfinUsersGet200ResponseInner(
          [void Function(SettingsJellyfinUsersGet200ResponseInnerBuilder)?
              updates]) =>
      (SettingsJellyfinUsersGet200ResponseInnerBuilder()..update(updates))
          ._build();

  _$SettingsJellyfinUsersGet200ResponseInner._(
      {this.username, this.id, this.thumb, this.email})
      : super._();
  @override
  SettingsJellyfinUsersGet200ResponseInner rebuild(
          void Function(SettingsJellyfinUsersGet200ResponseInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsJellyfinUsersGet200ResponseInnerBuilder toBuilder() =>
      SettingsJellyfinUsersGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsJellyfinUsersGet200ResponseInner &&
        username == other.username &&
        id == other.id &&
        thumb == other.thumb &&
        email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, thumb.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SettingsJellyfinUsersGet200ResponseInner')
          ..add('username', username)
          ..add('id', id)
          ..add('thumb', thumb)
          ..add('email', email))
        .toString();
  }
}

class SettingsJellyfinUsersGet200ResponseInnerBuilder
    implements
        Builder<SettingsJellyfinUsersGet200ResponseInner,
            SettingsJellyfinUsersGet200ResponseInnerBuilder> {
  _$SettingsJellyfinUsersGet200ResponseInner? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _thumb;
  String? get thumb => _$this._thumb;
  set thumb(String? thumb) => _$this._thumb = thumb;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  SettingsJellyfinUsersGet200ResponseInnerBuilder() {
    SettingsJellyfinUsersGet200ResponseInner._defaults(this);
  }

  SettingsJellyfinUsersGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _id = $v.id;
      _thumb = $v.thumb;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsJellyfinUsersGet200ResponseInner other) {
    _$v = other as _$SettingsJellyfinUsersGet200ResponseInner;
  }

  @override
  void update(
      void Function(SettingsJellyfinUsersGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsJellyfinUsersGet200ResponseInner build() => _build();

  _$SettingsJellyfinUsersGet200ResponseInner _build() {
    final _$result = _$v ??
        _$SettingsJellyfinUsersGet200ResponseInner._(
          username: username,
          id: id,
          thumb: thumb,
          email: email,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cache_get200_response_image_cache.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsCacheGet200ResponseImageCache
    extends SettingsCacheGet200ResponseImageCache {
  @override
  final SettingsCacheGet200ResponseImageCacheTmdb? tmdb;
  @override
  final SettingsCacheGet200ResponseImageCacheTmdb? avatar;

  factory _$SettingsCacheGet200ResponseImageCache(
          [void Function(SettingsCacheGet200ResponseImageCacheBuilder)?
              updates]) =>
      (SettingsCacheGet200ResponseImageCacheBuilder()..update(updates))
          ._build();

  _$SettingsCacheGet200ResponseImageCache._({this.tmdb, this.avatar})
      : super._();
  @override
  SettingsCacheGet200ResponseImageCache rebuild(
          void Function(SettingsCacheGet200ResponseImageCacheBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsCacheGet200ResponseImageCacheBuilder toBuilder() =>
      SettingsCacheGet200ResponseImageCacheBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsCacheGet200ResponseImageCache &&
        tmdb == other.tmdb &&
        avatar == other.avatar;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tmdb.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SettingsCacheGet200ResponseImageCache')
          ..add('tmdb', tmdb)
          ..add('avatar', avatar))
        .toString();
  }
}

class SettingsCacheGet200ResponseImageCacheBuilder
    implements
        Builder<SettingsCacheGet200ResponseImageCache,
            SettingsCacheGet200ResponseImageCacheBuilder> {
  _$SettingsCacheGet200ResponseImageCache? _$v;

  SettingsCacheGet200ResponseImageCacheTmdbBuilder? _tmdb;
  SettingsCacheGet200ResponseImageCacheTmdbBuilder get tmdb =>
      _$this._tmdb ??= SettingsCacheGet200ResponseImageCacheTmdbBuilder();
  set tmdb(SettingsCacheGet200ResponseImageCacheTmdbBuilder? tmdb) =>
      _$this._tmdb = tmdb;

  SettingsCacheGet200ResponseImageCacheTmdbBuilder? _avatar;
  SettingsCacheGet200ResponseImageCacheTmdbBuilder get avatar =>
      _$this._avatar ??= SettingsCacheGet200ResponseImageCacheTmdbBuilder();
  set avatar(SettingsCacheGet200ResponseImageCacheTmdbBuilder? avatar) =>
      _$this._avatar = avatar;

  SettingsCacheGet200ResponseImageCacheBuilder() {
    SettingsCacheGet200ResponseImageCache._defaults(this);
  }

  SettingsCacheGet200ResponseImageCacheBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tmdb = $v.tmdb?.toBuilder();
      _avatar = $v.avatar?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsCacheGet200ResponseImageCache other) {
    _$v = other as _$SettingsCacheGet200ResponseImageCache;
  }

  @override
  void update(
      void Function(SettingsCacheGet200ResponseImageCacheBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsCacheGet200ResponseImageCache build() => _build();

  _$SettingsCacheGet200ResponseImageCache _build() {
    _$SettingsCacheGet200ResponseImageCache _$result;
    try {
      _$result = _$v ??
          _$SettingsCacheGet200ResponseImageCache._(
            tmdb: _tmdb?.build(),
            avatar: _avatar?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tmdb';
        _tmdb?.build();
        _$failedField = 'avatar';
        _avatar?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SettingsCacheGet200ResponseImageCache',
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

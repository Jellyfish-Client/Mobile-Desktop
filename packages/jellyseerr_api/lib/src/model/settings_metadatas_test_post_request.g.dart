// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_metadatas_test_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsMetadatasTestPostRequest
    extends SettingsMetadatasTestPostRequest {
  @override
  final bool? tmdb;
  @override
  final bool? tvdb;

  factory _$SettingsMetadatasTestPostRequest(
          [void Function(SettingsMetadatasTestPostRequestBuilder)? updates]) =>
      (SettingsMetadatasTestPostRequestBuilder()..update(updates))._build();

  _$SettingsMetadatasTestPostRequest._({this.tmdb, this.tvdb}) : super._();
  @override
  SettingsMetadatasTestPostRequest rebuild(
          void Function(SettingsMetadatasTestPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsMetadatasTestPostRequestBuilder toBuilder() =>
      SettingsMetadatasTestPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsMetadatasTestPostRequest &&
        tmdb == other.tmdb &&
        tvdb == other.tvdb;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tmdb.hashCode);
    _$hash = $jc(_$hash, tvdb.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SettingsMetadatasTestPostRequest')
          ..add('tmdb', tmdb)
          ..add('tvdb', tvdb))
        .toString();
  }
}

class SettingsMetadatasTestPostRequestBuilder
    implements
        Builder<SettingsMetadatasTestPostRequest,
            SettingsMetadatasTestPostRequestBuilder> {
  _$SettingsMetadatasTestPostRequest? _$v;

  bool? _tmdb;
  bool? get tmdb => _$this._tmdb;
  set tmdb(bool? tmdb) => _$this._tmdb = tmdb;

  bool? _tvdb;
  bool? get tvdb => _$this._tvdb;
  set tvdb(bool? tvdb) => _$this._tvdb = tvdb;

  SettingsMetadatasTestPostRequestBuilder() {
    SettingsMetadatasTestPostRequest._defaults(this);
  }

  SettingsMetadatasTestPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tmdb = $v.tmdb;
      _tvdb = $v.tvdb;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsMetadatasTestPostRequest other) {
    _$v = other as _$SettingsMetadatasTestPostRequest;
  }

  @override
  void update(void Function(SettingsMetadatasTestPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsMetadatasTestPostRequest build() => _build();

  _$SettingsMetadatasTestPostRequest _build() {
    final _$result = _$v ??
        _$SettingsMetadatasTestPostRequest._(
          tmdb: tmdb,
          tvdb: tvdb,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

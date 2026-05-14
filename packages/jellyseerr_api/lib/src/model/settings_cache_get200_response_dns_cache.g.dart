// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cache_get200_response_dns_cache.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsCacheGet200ResponseDnsCache
    extends SettingsCacheGet200ResponseDnsCache {
  @override
  final SettingsCacheGet200ResponseDnsCacheStats? stats;
  @override
  final BuiltMap<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>?
      entries;

  factory _$SettingsCacheGet200ResponseDnsCache(
          [void Function(SettingsCacheGet200ResponseDnsCacheBuilder)?
              updates]) =>
      (SettingsCacheGet200ResponseDnsCacheBuilder()..update(updates))._build();

  _$SettingsCacheGet200ResponseDnsCache._({this.stats, this.entries})
      : super._();
  @override
  SettingsCacheGet200ResponseDnsCache rebuild(
          void Function(SettingsCacheGet200ResponseDnsCacheBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsCacheGet200ResponseDnsCacheBuilder toBuilder() =>
      SettingsCacheGet200ResponseDnsCacheBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsCacheGet200ResponseDnsCache &&
        stats == other.stats &&
        entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stats.hashCode);
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SettingsCacheGet200ResponseDnsCache')
          ..add('stats', stats)
          ..add('entries', entries))
        .toString();
  }
}

class SettingsCacheGet200ResponseDnsCacheBuilder
    implements
        Builder<SettingsCacheGet200ResponseDnsCache,
            SettingsCacheGet200ResponseDnsCacheBuilder> {
  _$SettingsCacheGet200ResponseDnsCache? _$v;

  SettingsCacheGet200ResponseDnsCacheStatsBuilder? _stats;
  SettingsCacheGet200ResponseDnsCacheStatsBuilder get stats =>
      _$this._stats ??= SettingsCacheGet200ResponseDnsCacheStatsBuilder();
  set stats(SettingsCacheGet200ResponseDnsCacheStatsBuilder? stats) =>
      _$this._stats = stats;

  MapBuilder<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>? _entries;
  MapBuilder<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>
      get entries => _$this._entries ??=
          MapBuilder<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>();
  set entries(
          MapBuilder<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>?
              entries) =>
      _$this._entries = entries;

  SettingsCacheGet200ResponseDnsCacheBuilder() {
    SettingsCacheGet200ResponseDnsCache._defaults(this);
  }

  SettingsCacheGet200ResponseDnsCacheBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stats = $v.stats?.toBuilder();
      _entries = $v.entries?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsCacheGet200ResponseDnsCache other) {
    _$v = other as _$SettingsCacheGet200ResponseDnsCache;
  }

  @override
  void update(
      void Function(SettingsCacheGet200ResponseDnsCacheBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsCacheGet200ResponseDnsCache build() => _build();

  _$SettingsCacheGet200ResponseDnsCache _build() {
    _$SettingsCacheGet200ResponseDnsCache _$result;
    try {
      _$result = _$v ??
          _$SettingsCacheGet200ResponseDnsCache._(
            stats: _stats?.build(),
            entries: _entries?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stats';
        _stats?.build();
        _$failedField = 'entries';
        _entries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'SettingsCacheGet200ResponseDnsCache',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

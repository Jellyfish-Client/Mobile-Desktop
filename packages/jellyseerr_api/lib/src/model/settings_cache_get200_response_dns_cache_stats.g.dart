// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cache_get200_response_dns_cache_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsCacheGet200ResponseDnsCacheStats
    extends SettingsCacheGet200ResponseDnsCacheStats {
  @override
  final num? size;
  @override
  final num? maxSize;
  @override
  final num? hits;
  @override
  final num? misses;
  @override
  final num? failures;
  @override
  final num? ipv4Fallbacks;
  @override
  final num? hitRate;

  factory _$SettingsCacheGet200ResponseDnsCacheStats(
          [void Function(SettingsCacheGet200ResponseDnsCacheStatsBuilder)?
              updates]) =>
      (SettingsCacheGet200ResponseDnsCacheStatsBuilder()..update(updates))
          ._build();

  _$SettingsCacheGet200ResponseDnsCacheStats._(
      {this.size,
      this.maxSize,
      this.hits,
      this.misses,
      this.failures,
      this.ipv4Fallbacks,
      this.hitRate})
      : super._();
  @override
  SettingsCacheGet200ResponseDnsCacheStats rebuild(
          void Function(SettingsCacheGet200ResponseDnsCacheStatsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsCacheGet200ResponseDnsCacheStatsBuilder toBuilder() =>
      SettingsCacheGet200ResponseDnsCacheStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsCacheGet200ResponseDnsCacheStats &&
        size == other.size &&
        maxSize == other.maxSize &&
        hits == other.hits &&
        misses == other.misses &&
        failures == other.failures &&
        ipv4Fallbacks == other.ipv4Fallbacks &&
        hitRate == other.hitRate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, maxSize.hashCode);
    _$hash = $jc(_$hash, hits.hashCode);
    _$hash = $jc(_$hash, misses.hashCode);
    _$hash = $jc(_$hash, failures.hashCode);
    _$hash = $jc(_$hash, ipv4Fallbacks.hashCode);
    _$hash = $jc(_$hash, hitRate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'SettingsCacheGet200ResponseDnsCacheStats')
          ..add('size', size)
          ..add('maxSize', maxSize)
          ..add('hits', hits)
          ..add('misses', misses)
          ..add('failures', failures)
          ..add('ipv4Fallbacks', ipv4Fallbacks)
          ..add('hitRate', hitRate))
        .toString();
  }
}

class SettingsCacheGet200ResponseDnsCacheStatsBuilder
    implements
        Builder<SettingsCacheGet200ResponseDnsCacheStats,
            SettingsCacheGet200ResponseDnsCacheStatsBuilder> {
  _$SettingsCacheGet200ResponseDnsCacheStats? _$v;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  num? _maxSize;
  num? get maxSize => _$this._maxSize;
  set maxSize(num? maxSize) => _$this._maxSize = maxSize;

  num? _hits;
  num? get hits => _$this._hits;
  set hits(num? hits) => _$this._hits = hits;

  num? _misses;
  num? get misses => _$this._misses;
  set misses(num? misses) => _$this._misses = misses;

  num? _failures;
  num? get failures => _$this._failures;
  set failures(num? failures) => _$this._failures = failures;

  num? _ipv4Fallbacks;
  num? get ipv4Fallbacks => _$this._ipv4Fallbacks;
  set ipv4Fallbacks(num? ipv4Fallbacks) =>
      _$this._ipv4Fallbacks = ipv4Fallbacks;

  num? _hitRate;
  num? get hitRate => _$this._hitRate;
  set hitRate(num? hitRate) => _$this._hitRate = hitRate;

  SettingsCacheGet200ResponseDnsCacheStatsBuilder() {
    SettingsCacheGet200ResponseDnsCacheStats._defaults(this);
  }

  SettingsCacheGet200ResponseDnsCacheStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _size = $v.size;
      _maxSize = $v.maxSize;
      _hits = $v.hits;
      _misses = $v.misses;
      _failures = $v.failures;
      _ipv4Fallbacks = $v.ipv4Fallbacks;
      _hitRate = $v.hitRate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsCacheGet200ResponseDnsCacheStats other) {
    _$v = other as _$SettingsCacheGet200ResponseDnsCacheStats;
  }

  @override
  void update(
      void Function(SettingsCacheGet200ResponseDnsCacheStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsCacheGet200ResponseDnsCacheStats build() => _build();

  _$SettingsCacheGet200ResponseDnsCacheStats _build() {
    final _$result = _$v ??
        _$SettingsCacheGet200ResponseDnsCacheStats._(
          size: size,
          maxSize: maxSize,
          hits: hits,
          misses: misses,
          failures: failures,
          ipv4Fallbacks: ipv4Fallbacks,
          hitRate: hitRate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

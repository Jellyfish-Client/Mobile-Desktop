// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_settings_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MetadataSettingsSettingsTvEnum _$metadataSettingsSettingsTvEnum_tvdb =
    const MetadataSettingsSettingsTvEnum._('tvdb');
const MetadataSettingsSettingsTvEnum _$metadataSettingsSettingsTvEnum_tmdb =
    const MetadataSettingsSettingsTvEnum._('tmdb');

MetadataSettingsSettingsTvEnum _$metadataSettingsSettingsTvEnumValueOf(
    String name) {
  switch (name) {
    case 'tvdb':
      return _$metadataSettingsSettingsTvEnum_tvdb;
    case 'tmdb':
      return _$metadataSettingsSettingsTvEnum_tmdb;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MetadataSettingsSettingsTvEnum>
    _$metadataSettingsSettingsTvEnumValues = BuiltSet<
        MetadataSettingsSettingsTvEnum>(const <MetadataSettingsSettingsTvEnum>[
  _$metadataSettingsSettingsTvEnum_tvdb,
  _$metadataSettingsSettingsTvEnum_tmdb,
]);

const MetadataSettingsSettingsAnimeEnum
    _$metadataSettingsSettingsAnimeEnum_tvdb =
    const MetadataSettingsSettingsAnimeEnum._('tvdb');
const MetadataSettingsSettingsAnimeEnum
    _$metadataSettingsSettingsAnimeEnum_tmdb =
    const MetadataSettingsSettingsAnimeEnum._('tmdb');

MetadataSettingsSettingsAnimeEnum _$metadataSettingsSettingsAnimeEnumValueOf(
    String name) {
  switch (name) {
    case 'tvdb':
      return _$metadataSettingsSettingsAnimeEnum_tvdb;
    case 'tmdb':
      return _$metadataSettingsSettingsAnimeEnum_tmdb;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MetadataSettingsSettingsAnimeEnum>
    _$metadataSettingsSettingsAnimeEnumValues = BuiltSet<
        MetadataSettingsSettingsAnimeEnum>(const <MetadataSettingsSettingsAnimeEnum>[
  _$metadataSettingsSettingsAnimeEnum_tvdb,
  _$metadataSettingsSettingsAnimeEnum_tmdb,
]);

Serializer<MetadataSettingsSettingsTvEnum>
    _$metadataSettingsSettingsTvEnumSerializer =
    _$MetadataSettingsSettingsTvEnumSerializer();
Serializer<MetadataSettingsSettingsAnimeEnum>
    _$metadataSettingsSettingsAnimeEnumSerializer =
    _$MetadataSettingsSettingsAnimeEnumSerializer();

class _$MetadataSettingsSettingsTvEnumSerializer
    implements PrimitiveSerializer<MetadataSettingsSettingsTvEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tvdb': 'tvdb',
    'tmdb': 'tmdb',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'tvdb': 'tvdb',
    'tmdb': 'tmdb',
  };

  @override
  final Iterable<Type> types = const <Type>[MetadataSettingsSettingsTvEnum];
  @override
  final String wireName = 'MetadataSettingsSettingsTvEnum';

  @override
  Object serialize(
          Serializers serializers, MetadataSettingsSettingsTvEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MetadataSettingsSettingsTvEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MetadataSettingsSettingsTvEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MetadataSettingsSettingsAnimeEnumSerializer
    implements PrimitiveSerializer<MetadataSettingsSettingsAnimeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tvdb': 'tvdb',
    'tmdb': 'tmdb',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'tvdb': 'tvdb',
    'tmdb': 'tmdb',
  };

  @override
  final Iterable<Type> types = const <Type>[MetadataSettingsSettingsAnimeEnum];
  @override
  final String wireName = 'MetadataSettingsSettingsAnimeEnum';

  @override
  Object serialize(
          Serializers serializers, MetadataSettingsSettingsAnimeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MetadataSettingsSettingsAnimeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MetadataSettingsSettingsAnimeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MetadataSettingsSettings extends MetadataSettingsSettings {
  @override
  final MetadataSettingsSettingsTvEnum? tv;
  @override
  final MetadataSettingsSettingsAnimeEnum? anime;

  factory _$MetadataSettingsSettings(
          [void Function(MetadataSettingsSettingsBuilder)? updates]) =>
      (MetadataSettingsSettingsBuilder()..update(updates))._build();

  _$MetadataSettingsSettings._({this.tv, this.anime}) : super._();
  @override
  MetadataSettingsSettings rebuild(
          void Function(MetadataSettingsSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MetadataSettingsSettingsBuilder toBuilder() =>
      MetadataSettingsSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetadataSettingsSettings &&
        tv == other.tv &&
        anime == other.anime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tv.hashCode);
    _$hash = $jc(_$hash, anime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MetadataSettingsSettings')
          ..add('tv', tv)
          ..add('anime', anime))
        .toString();
  }
}

class MetadataSettingsSettingsBuilder
    implements
        Builder<MetadataSettingsSettings, MetadataSettingsSettingsBuilder> {
  _$MetadataSettingsSettings? _$v;

  MetadataSettingsSettingsTvEnum? _tv;
  MetadataSettingsSettingsTvEnum? get tv => _$this._tv;
  set tv(MetadataSettingsSettingsTvEnum? tv) => _$this._tv = tv;

  MetadataSettingsSettingsAnimeEnum? _anime;
  MetadataSettingsSettingsAnimeEnum? get anime => _$this._anime;
  set anime(MetadataSettingsSettingsAnimeEnum? anime) => _$this._anime = anime;

  MetadataSettingsSettingsBuilder() {
    MetadataSettingsSettings._defaults(this);
  }

  MetadataSettingsSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tv = $v.tv;
      _anime = $v.anime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MetadataSettingsSettings other) {
    _$v = other as _$MetadataSettingsSettings;
  }

  @override
  void update(void Function(MetadataSettingsSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetadataSettingsSettings build() => _build();

  _$MetadataSettingsSettings _build() {
    final _$result = _$v ??
        _$MetadataSettingsSettings._(
          tv: tv,
          anime: anime,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

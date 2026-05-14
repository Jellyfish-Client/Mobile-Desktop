// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MetadataSettings extends MetadataSettings {
  @override
  final MetadataSettingsSettings? settings;

  factory _$MetadataSettings(
          [void Function(MetadataSettingsBuilder)? updates]) =>
      (MetadataSettingsBuilder()..update(updates))._build();

  _$MetadataSettings._({this.settings}) : super._();
  @override
  MetadataSettings rebuild(void Function(MetadataSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MetadataSettingsBuilder toBuilder() =>
      MetadataSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetadataSettings && settings == other.settings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MetadataSettings')
          ..add('settings', settings))
        .toString();
  }
}

class MetadataSettingsBuilder
    implements Builder<MetadataSettings, MetadataSettingsBuilder> {
  _$MetadataSettings? _$v;

  MetadataSettingsSettingsBuilder? _settings;
  MetadataSettingsSettingsBuilder get settings =>
      _$this._settings ??= MetadataSettingsSettingsBuilder();
  set settings(MetadataSettingsSettingsBuilder? settings) =>
      _$this._settings = settings;

  MetadataSettingsBuilder() {
    MetadataSettings._defaults(this);
  }

  MetadataSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _settings = $v.settings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MetadataSettings other) {
    _$v = other as _$MetadataSettings;
  }

  @override
  void update(void Function(MetadataSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetadataSettings build() => _build();

  _$MetadataSettings _build() {
    _$MetadataSettings _$result;
    try {
      _$result = _$v ??
          _$MetadataSettings._(
            settings: _settings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'settings';
        _settings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MetadataSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ntfy_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NtfySettings extends NtfySettings {
  @override
  final bool? enabled;
  @override
  final num? types;
  @override
  final NtfySettingsOptions? options;

  factory _$NtfySettings([void Function(NtfySettingsBuilder)? updates]) =>
      (NtfySettingsBuilder()..update(updates))._build();

  _$NtfySettings._({this.enabled, this.types, this.options}) : super._();
  @override
  NtfySettings rebuild(void Function(NtfySettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NtfySettingsBuilder toBuilder() => NtfySettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NtfySettings &&
        enabled == other.enabled &&
        types == other.types &&
        options == other.options;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, types.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NtfySettings')
          ..add('enabled', enabled)
          ..add('types', types)
          ..add('options', options))
        .toString();
  }
}

class NtfySettingsBuilder
    implements Builder<NtfySettings, NtfySettingsBuilder> {
  _$NtfySettings? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  num? _types;
  num? get types => _$this._types;
  set types(num? types) => _$this._types = types;

  NtfySettingsOptionsBuilder? _options;
  NtfySettingsOptionsBuilder get options =>
      _$this._options ??= NtfySettingsOptionsBuilder();
  set options(NtfySettingsOptionsBuilder? options) => _$this._options = options;

  NtfySettingsBuilder() {
    NtfySettings._defaults(this);
  }

  NtfySettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _types = $v.types;
      _options = $v.options?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NtfySettings other) {
    _$v = other as _$NtfySettings;
  }

  @override
  void update(void Function(NtfySettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NtfySettings build() => _build();

  _$NtfySettings _build() {
    _$NtfySettings _$result;
    try {
      _$result = _$v ??
          _$NtfySettings._(
            enabled: enabled,
            types: types,
            options: _options?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        _options?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NtfySettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

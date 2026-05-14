// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PublicSettings extends PublicSettings {
  @override
  final bool initialized;
  @override
  final String plexClientIdentifier;

  factory _$PublicSettings([void Function(PublicSettingsBuilder)? updates]) =>
      (PublicSettingsBuilder()..update(updates))._build();

  _$PublicSettings._(
      {required this.initialized, required this.plexClientIdentifier})
      : super._();
  @override
  PublicSettings rebuild(void Function(PublicSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PublicSettingsBuilder toBuilder() => PublicSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublicSettings &&
        initialized == other.initialized &&
        plexClientIdentifier == other.plexClientIdentifier;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, initialized.hashCode);
    _$hash = $jc(_$hash, plexClientIdentifier.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublicSettings')
          ..add('initialized', initialized)
          ..add('plexClientIdentifier', plexClientIdentifier))
        .toString();
  }
}

class PublicSettingsBuilder
    implements Builder<PublicSettings, PublicSettingsBuilder> {
  _$PublicSettings? _$v;

  bool? _initialized;
  bool? get initialized => _$this._initialized;
  set initialized(bool? initialized) => _$this._initialized = initialized;

  String? _plexClientIdentifier;
  String? get plexClientIdentifier => _$this._plexClientIdentifier;
  set plexClientIdentifier(String? plexClientIdentifier) =>
      _$this._plexClientIdentifier = plexClientIdentifier;

  PublicSettingsBuilder() {
    PublicSettings._defaults(this);
  }

  PublicSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _initialized = $v.initialized;
      _plexClientIdentifier = $v.plexClientIdentifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublicSettings other) {
    _$v = other as _$PublicSettings;
  }

  @override
  void update(void Function(PublicSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublicSettings build() => _build();

  _$PublicSettings _build() {
    final _$result = _$v ??
        _$PublicSettings._(
          initialized: BuiltValueNullFieldError.checkNotNull(
              initialized, r'PublicSettings', 'initialized'),
          plexClientIdentifier: BuiltValueNullFieldError.checkNotNull(
              plexClientIdentifier, r'PublicSettings', 'plexClientIdentifier'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

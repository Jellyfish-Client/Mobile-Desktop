// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MainSettings extends MainSettings {
  @override
  final String? apiKey;
  @override
  final String? appLanguage;
  @override
  final String? applicationTitle;
  @override
  final String? applicationUrl;
  @override
  final bool? hideAvailable;
  @override
  final bool? partialRequestsEnabled;
  @override
  final bool? localLogin;
  @override
  final num? mediaServerType;
  @override
  final bool? newPlexLogin;
  @override
  final num? defaultPermissions;
  @override
  final bool? enableSpecialEpisodes;

  factory _$MainSettings([void Function(MainSettingsBuilder)? updates]) =>
      (MainSettingsBuilder()..update(updates))._build();

  _$MainSettings._(
      {this.apiKey,
      this.appLanguage,
      this.applicationTitle,
      this.applicationUrl,
      this.hideAvailable,
      this.partialRequestsEnabled,
      this.localLogin,
      this.mediaServerType,
      this.newPlexLogin,
      this.defaultPermissions,
      this.enableSpecialEpisodes})
      : super._();
  @override
  MainSettings rebuild(void Function(MainSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MainSettingsBuilder toBuilder() => MainSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MainSettings &&
        apiKey == other.apiKey &&
        appLanguage == other.appLanguage &&
        applicationTitle == other.applicationTitle &&
        applicationUrl == other.applicationUrl &&
        hideAvailable == other.hideAvailable &&
        partialRequestsEnabled == other.partialRequestsEnabled &&
        localLogin == other.localLogin &&
        mediaServerType == other.mediaServerType &&
        newPlexLogin == other.newPlexLogin &&
        defaultPermissions == other.defaultPermissions &&
        enableSpecialEpisodes == other.enableSpecialEpisodes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, apiKey.hashCode);
    _$hash = $jc(_$hash, appLanguage.hashCode);
    _$hash = $jc(_$hash, applicationTitle.hashCode);
    _$hash = $jc(_$hash, applicationUrl.hashCode);
    _$hash = $jc(_$hash, hideAvailable.hashCode);
    _$hash = $jc(_$hash, partialRequestsEnabled.hashCode);
    _$hash = $jc(_$hash, localLogin.hashCode);
    _$hash = $jc(_$hash, mediaServerType.hashCode);
    _$hash = $jc(_$hash, newPlexLogin.hashCode);
    _$hash = $jc(_$hash, defaultPermissions.hashCode);
    _$hash = $jc(_$hash, enableSpecialEpisodes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MainSettings')
          ..add('apiKey', apiKey)
          ..add('appLanguage', appLanguage)
          ..add('applicationTitle', applicationTitle)
          ..add('applicationUrl', applicationUrl)
          ..add('hideAvailable', hideAvailable)
          ..add('partialRequestsEnabled', partialRequestsEnabled)
          ..add('localLogin', localLogin)
          ..add('mediaServerType', mediaServerType)
          ..add('newPlexLogin', newPlexLogin)
          ..add('defaultPermissions', defaultPermissions)
          ..add('enableSpecialEpisodes', enableSpecialEpisodes))
        .toString();
  }
}

class MainSettingsBuilder
    implements Builder<MainSettings, MainSettingsBuilder> {
  _$MainSettings? _$v;

  String? _apiKey;
  String? get apiKey => _$this._apiKey;
  set apiKey(String? apiKey) => _$this._apiKey = apiKey;

  String? _appLanguage;
  String? get appLanguage => _$this._appLanguage;
  set appLanguage(String? appLanguage) => _$this._appLanguage = appLanguage;

  String? _applicationTitle;
  String? get applicationTitle => _$this._applicationTitle;
  set applicationTitle(String? applicationTitle) =>
      _$this._applicationTitle = applicationTitle;

  String? _applicationUrl;
  String? get applicationUrl => _$this._applicationUrl;
  set applicationUrl(String? applicationUrl) =>
      _$this._applicationUrl = applicationUrl;

  bool? _hideAvailable;
  bool? get hideAvailable => _$this._hideAvailable;
  set hideAvailable(bool? hideAvailable) =>
      _$this._hideAvailable = hideAvailable;

  bool? _partialRequestsEnabled;
  bool? get partialRequestsEnabled => _$this._partialRequestsEnabled;
  set partialRequestsEnabled(bool? partialRequestsEnabled) =>
      _$this._partialRequestsEnabled = partialRequestsEnabled;

  bool? _localLogin;
  bool? get localLogin => _$this._localLogin;
  set localLogin(bool? localLogin) => _$this._localLogin = localLogin;

  num? _mediaServerType;
  num? get mediaServerType => _$this._mediaServerType;
  set mediaServerType(num? mediaServerType) =>
      _$this._mediaServerType = mediaServerType;

  bool? _newPlexLogin;
  bool? get newPlexLogin => _$this._newPlexLogin;
  set newPlexLogin(bool? newPlexLogin) => _$this._newPlexLogin = newPlexLogin;

  num? _defaultPermissions;
  num? get defaultPermissions => _$this._defaultPermissions;
  set defaultPermissions(num? defaultPermissions) =>
      _$this._defaultPermissions = defaultPermissions;

  bool? _enableSpecialEpisodes;
  bool? get enableSpecialEpisodes => _$this._enableSpecialEpisodes;
  set enableSpecialEpisodes(bool? enableSpecialEpisodes) =>
      _$this._enableSpecialEpisodes = enableSpecialEpisodes;

  MainSettingsBuilder() {
    MainSettings._defaults(this);
  }

  MainSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _apiKey = $v.apiKey;
      _appLanguage = $v.appLanguage;
      _applicationTitle = $v.applicationTitle;
      _applicationUrl = $v.applicationUrl;
      _hideAvailable = $v.hideAvailable;
      _partialRequestsEnabled = $v.partialRequestsEnabled;
      _localLogin = $v.localLogin;
      _mediaServerType = $v.mediaServerType;
      _newPlexLogin = $v.newPlexLogin;
      _defaultPermissions = $v.defaultPermissions;
      _enableSpecialEpisodes = $v.enableSpecialEpisodes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MainSettings other) {
    _$v = other as _$MainSettings;
  }

  @override
  void update(void Function(MainSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MainSettings build() => _build();

  _$MainSettings _build() {
    final _$result = _$v ??
        _$MainSettings._(
          apiKey: apiKey,
          appLanguage: appLanguage,
          applicationTitle: applicationTitle,
          applicationUrl: applicationUrl,
          hideAvailable: hideAvailable,
          partialRequestsEnabled: partialRequestsEnabled,
          localLogin: localLogin,
          mediaServerType: mediaServerType,
          newPlexLogin: newPlexLogin,
          defaultPermissions: defaultPermissions,
          enableSpecialEpisodes: enableSpecialEpisodes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

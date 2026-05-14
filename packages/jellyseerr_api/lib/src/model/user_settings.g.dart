// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserSettings extends UserSettings {
  @override
  final String? username;
  @override
  final String? email;
  @override
  final String? discordId;
  @override
  final String? locale;
  @override
  final String? discoverRegion;
  @override
  final String? streamingRegion;
  @override
  final String? originalLanguage;
  @override
  final num? movieQuotaLimit;
  @override
  final num? movieQuotaDays;
  @override
  final num? tvQuotaLimit;
  @override
  final num? tvQuotaDays;
  @override
  final num? globalMovieQuotaDays;
  @override
  final num? globalMovieQuotaLimit;
  @override
  final num? globalTvQuotaLimit;
  @override
  final num? globalTvQuotaDays;
  @override
  final bool? watchlistSyncMovies;
  @override
  final bool? watchlistSyncTv;

  factory _$UserSettings([void Function(UserSettingsBuilder)? updates]) =>
      (UserSettingsBuilder()..update(updates))._build();

  _$UserSettings._(
      {this.username,
      this.email,
      this.discordId,
      this.locale,
      this.discoverRegion,
      this.streamingRegion,
      this.originalLanguage,
      this.movieQuotaLimit,
      this.movieQuotaDays,
      this.tvQuotaLimit,
      this.tvQuotaDays,
      this.globalMovieQuotaDays,
      this.globalMovieQuotaLimit,
      this.globalTvQuotaLimit,
      this.globalTvQuotaDays,
      this.watchlistSyncMovies,
      this.watchlistSyncTv})
      : super._();
  @override
  UserSettings rebuild(void Function(UserSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserSettingsBuilder toBuilder() => UserSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSettings &&
        username == other.username &&
        email == other.email &&
        discordId == other.discordId &&
        locale == other.locale &&
        discoverRegion == other.discoverRegion &&
        streamingRegion == other.streamingRegion &&
        originalLanguage == other.originalLanguage &&
        movieQuotaLimit == other.movieQuotaLimit &&
        movieQuotaDays == other.movieQuotaDays &&
        tvQuotaLimit == other.tvQuotaLimit &&
        tvQuotaDays == other.tvQuotaDays &&
        globalMovieQuotaDays == other.globalMovieQuotaDays &&
        globalMovieQuotaLimit == other.globalMovieQuotaLimit &&
        globalTvQuotaLimit == other.globalTvQuotaLimit &&
        globalTvQuotaDays == other.globalTvQuotaDays &&
        watchlistSyncMovies == other.watchlistSyncMovies &&
        watchlistSyncTv == other.watchlistSyncTv;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, discordId.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, discoverRegion.hashCode);
    _$hash = $jc(_$hash, streamingRegion.hashCode);
    _$hash = $jc(_$hash, originalLanguage.hashCode);
    _$hash = $jc(_$hash, movieQuotaLimit.hashCode);
    _$hash = $jc(_$hash, movieQuotaDays.hashCode);
    _$hash = $jc(_$hash, tvQuotaLimit.hashCode);
    _$hash = $jc(_$hash, tvQuotaDays.hashCode);
    _$hash = $jc(_$hash, globalMovieQuotaDays.hashCode);
    _$hash = $jc(_$hash, globalMovieQuotaLimit.hashCode);
    _$hash = $jc(_$hash, globalTvQuotaLimit.hashCode);
    _$hash = $jc(_$hash, globalTvQuotaDays.hashCode);
    _$hash = $jc(_$hash, watchlistSyncMovies.hashCode);
    _$hash = $jc(_$hash, watchlistSyncTv.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserSettings')
          ..add('username', username)
          ..add('email', email)
          ..add('discordId', discordId)
          ..add('locale', locale)
          ..add('discoverRegion', discoverRegion)
          ..add('streamingRegion', streamingRegion)
          ..add('originalLanguage', originalLanguage)
          ..add('movieQuotaLimit', movieQuotaLimit)
          ..add('movieQuotaDays', movieQuotaDays)
          ..add('tvQuotaLimit', tvQuotaLimit)
          ..add('tvQuotaDays', tvQuotaDays)
          ..add('globalMovieQuotaDays', globalMovieQuotaDays)
          ..add('globalMovieQuotaLimit', globalMovieQuotaLimit)
          ..add('globalTvQuotaLimit', globalTvQuotaLimit)
          ..add('globalTvQuotaDays', globalTvQuotaDays)
          ..add('watchlistSyncMovies', watchlistSyncMovies)
          ..add('watchlistSyncTv', watchlistSyncTv))
        .toString();
  }
}

class UserSettingsBuilder
    implements Builder<UserSettings, UserSettingsBuilder> {
  _$UserSettings? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _discordId;
  String? get discordId => _$this._discordId;
  set discordId(String? discordId) => _$this._discordId = discordId;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  String? _discoverRegion;
  String? get discoverRegion => _$this._discoverRegion;
  set discoverRegion(String? discoverRegion) =>
      _$this._discoverRegion = discoverRegion;

  String? _streamingRegion;
  String? get streamingRegion => _$this._streamingRegion;
  set streamingRegion(String? streamingRegion) =>
      _$this._streamingRegion = streamingRegion;

  String? _originalLanguage;
  String? get originalLanguage => _$this._originalLanguage;
  set originalLanguage(String? originalLanguage) =>
      _$this._originalLanguage = originalLanguage;

  num? _movieQuotaLimit;
  num? get movieQuotaLimit => _$this._movieQuotaLimit;
  set movieQuotaLimit(num? movieQuotaLimit) =>
      _$this._movieQuotaLimit = movieQuotaLimit;

  num? _movieQuotaDays;
  num? get movieQuotaDays => _$this._movieQuotaDays;
  set movieQuotaDays(num? movieQuotaDays) =>
      _$this._movieQuotaDays = movieQuotaDays;

  num? _tvQuotaLimit;
  num? get tvQuotaLimit => _$this._tvQuotaLimit;
  set tvQuotaLimit(num? tvQuotaLimit) => _$this._tvQuotaLimit = tvQuotaLimit;

  num? _tvQuotaDays;
  num? get tvQuotaDays => _$this._tvQuotaDays;
  set tvQuotaDays(num? tvQuotaDays) => _$this._tvQuotaDays = tvQuotaDays;

  num? _globalMovieQuotaDays;
  num? get globalMovieQuotaDays => _$this._globalMovieQuotaDays;
  set globalMovieQuotaDays(num? globalMovieQuotaDays) =>
      _$this._globalMovieQuotaDays = globalMovieQuotaDays;

  num? _globalMovieQuotaLimit;
  num? get globalMovieQuotaLimit => _$this._globalMovieQuotaLimit;
  set globalMovieQuotaLimit(num? globalMovieQuotaLimit) =>
      _$this._globalMovieQuotaLimit = globalMovieQuotaLimit;

  num? _globalTvQuotaLimit;
  num? get globalTvQuotaLimit => _$this._globalTvQuotaLimit;
  set globalTvQuotaLimit(num? globalTvQuotaLimit) =>
      _$this._globalTvQuotaLimit = globalTvQuotaLimit;

  num? _globalTvQuotaDays;
  num? get globalTvQuotaDays => _$this._globalTvQuotaDays;
  set globalTvQuotaDays(num? globalTvQuotaDays) =>
      _$this._globalTvQuotaDays = globalTvQuotaDays;

  bool? _watchlistSyncMovies;
  bool? get watchlistSyncMovies => _$this._watchlistSyncMovies;
  set watchlistSyncMovies(bool? watchlistSyncMovies) =>
      _$this._watchlistSyncMovies = watchlistSyncMovies;

  bool? _watchlistSyncTv;
  bool? get watchlistSyncTv => _$this._watchlistSyncTv;
  set watchlistSyncTv(bool? watchlistSyncTv) =>
      _$this._watchlistSyncTv = watchlistSyncTv;

  UserSettingsBuilder() {
    UserSettings._defaults(this);
  }

  UserSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _email = $v.email;
      _discordId = $v.discordId;
      _locale = $v.locale;
      _discoverRegion = $v.discoverRegion;
      _streamingRegion = $v.streamingRegion;
      _originalLanguage = $v.originalLanguage;
      _movieQuotaLimit = $v.movieQuotaLimit;
      _movieQuotaDays = $v.movieQuotaDays;
      _tvQuotaLimit = $v.tvQuotaLimit;
      _tvQuotaDays = $v.tvQuotaDays;
      _globalMovieQuotaDays = $v.globalMovieQuotaDays;
      _globalMovieQuotaLimit = $v.globalMovieQuotaLimit;
      _globalTvQuotaLimit = $v.globalTvQuotaLimit;
      _globalTvQuotaDays = $v.globalTvQuotaDays;
      _watchlistSyncMovies = $v.watchlistSyncMovies;
      _watchlistSyncTv = $v.watchlistSyncTv;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserSettings other) {
    _$v = other as _$UserSettings;
  }

  @override
  void update(void Function(UserSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserSettings build() => _build();

  _$UserSettings _build() {
    final _$result = _$v ??
        _$UserSettings._(
          username: username,
          email: email,
          discordId: discordId,
          locale: locale,
          discoverRegion: discoverRegion,
          streamingRegion: streamingRegion,
          originalLanguage: originalLanguage,
          movieQuotaLimit: movieQuotaLimit,
          movieQuotaDays: movieQuotaDays,
          tvQuotaLimit: tvQuotaLimit,
          tvQuotaDays: tvQuotaDays,
          globalMovieQuotaDays: globalMovieQuotaDays,
          globalMovieQuotaLimit: globalMovieQuotaLimit,
          globalTvQuotaLimit: globalTvQuotaLimit,
          globalTvQuotaDays: globalTvQuotaDays,
          watchlistSyncMovies: watchlistSyncMovies,
          watchlistSyncTv: watchlistSyncTv,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Blocklist extends Blocklist {
  @override
  final num? tmdbId;
  @override
  final String? title;
  @override
  final MediaInfo? media;
  @override
  final num? userId;

  factory _$Blocklist([void Function(BlocklistBuilder)? updates]) =>
      (BlocklistBuilder()..update(updates))._build();

  _$Blocklist._({this.tmdbId, this.title, this.media, this.userId}) : super._();
  @override
  Blocklist rebuild(void Function(BlocklistBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BlocklistBuilder toBuilder() => BlocklistBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Blocklist &&
        tmdbId == other.tmdbId &&
        title == other.title &&
        media == other.media &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tmdbId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Blocklist')
          ..add('tmdbId', tmdbId)
          ..add('title', title)
          ..add('media', media)
          ..add('userId', userId))
        .toString();
  }
}

class BlocklistBuilder implements Builder<Blocklist, BlocklistBuilder> {
  _$Blocklist? _$v;

  num? _tmdbId;
  num? get tmdbId => _$this._tmdbId;
  set tmdbId(num? tmdbId) => _$this._tmdbId = tmdbId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  MediaInfoBuilder? _media;
  MediaInfoBuilder get media => _$this._media ??= MediaInfoBuilder();
  set media(MediaInfoBuilder? media) => _$this._media = media;

  num? _userId;
  num? get userId => _$this._userId;
  set userId(num? userId) => _$this._userId = userId;

  BlocklistBuilder() {
    Blocklist._defaults(this);
  }

  BlocklistBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tmdbId = $v.tmdbId;
      _title = $v.title;
      _media = $v.media?.toBuilder();
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Blocklist other) {
    _$v = other as _$Blocklist;
  }

  @override
  void update(void Function(BlocklistBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Blocklist build() => _build();

  _$Blocklist _build() {
    _$Blocklist _$result;
    try {
      _$result = _$v ??
          _$Blocklist._(
            tmdbId: tmdbId,
            title: title,
            media: _media?.build(),
            userId: userId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'media';
        _media?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Blocklist', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

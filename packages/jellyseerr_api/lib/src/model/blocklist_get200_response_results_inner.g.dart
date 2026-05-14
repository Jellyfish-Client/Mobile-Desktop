// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist_get200_response_results_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BlocklistGet200ResponseResultsInner
    extends BlocklistGet200ResponseResultsInner {
  @override
  final User? user;
  @override
  final String? createdAt;
  @override
  final num? id;
  @override
  final String? mediaType;
  @override
  final String? title;
  @override
  final num? tmdbId;

  factory _$BlocklistGet200ResponseResultsInner(
          [void Function(BlocklistGet200ResponseResultsInnerBuilder)?
              updates]) =>
      (BlocklistGet200ResponseResultsInnerBuilder()..update(updates))._build();

  _$BlocklistGet200ResponseResultsInner._(
      {this.user,
      this.createdAt,
      this.id,
      this.mediaType,
      this.title,
      this.tmdbId})
      : super._();
  @override
  BlocklistGet200ResponseResultsInner rebuild(
          void Function(BlocklistGet200ResponseResultsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BlocklistGet200ResponseResultsInnerBuilder toBuilder() =>
      BlocklistGet200ResponseResultsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BlocklistGet200ResponseResultsInner &&
        user == other.user &&
        createdAt == other.createdAt &&
        id == other.id &&
        mediaType == other.mediaType &&
        title == other.title &&
        tmdbId == other.tmdbId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, mediaType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, tmdbId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BlocklistGet200ResponseResultsInner')
          ..add('user', user)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('mediaType', mediaType)
          ..add('title', title)
          ..add('tmdbId', tmdbId))
        .toString();
  }
}

class BlocklistGet200ResponseResultsInnerBuilder
    implements
        Builder<BlocklistGet200ResponseResultsInner,
            BlocklistGet200ResponseResultsInnerBuilder> {
  _$BlocklistGet200ResponseResultsInner? _$v;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  num? _id;
  num? get id => _$this._id;
  set id(num? id) => _$this._id = id;

  String? _mediaType;
  String? get mediaType => _$this._mediaType;
  set mediaType(String? mediaType) => _$this._mediaType = mediaType;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  num? _tmdbId;
  num? get tmdbId => _$this._tmdbId;
  set tmdbId(num? tmdbId) => _$this._tmdbId = tmdbId;

  BlocklistGet200ResponseResultsInnerBuilder() {
    BlocklistGet200ResponseResultsInner._defaults(this);
  }

  BlocklistGet200ResponseResultsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user?.toBuilder();
      _createdAt = $v.createdAt;
      _id = $v.id;
      _mediaType = $v.mediaType;
      _title = $v.title;
      _tmdbId = $v.tmdbId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BlocklistGet200ResponseResultsInner other) {
    _$v = other as _$BlocklistGet200ResponseResultsInner;
  }

  @override
  void update(
      void Function(BlocklistGet200ResponseResultsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BlocklistGet200ResponseResultsInner build() => _build();

  _$BlocklistGet200ResponseResultsInner _build() {
    _$BlocklistGet200ResponseResultsInner _$result;
    try {
      _$result = _$v ??
          _$BlocklistGet200ResponseResultsInner._(
            user: _user?.build(),
            createdAt: createdAt,
            id: id,
            mediaType: mediaType,
            title: title,
            tmdbId: tmdbId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'BlocklistGet200ResponseResultsInner',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

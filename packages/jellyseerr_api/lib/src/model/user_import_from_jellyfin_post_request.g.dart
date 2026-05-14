// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_import_from_jellyfin_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserImportFromJellyfinPostRequest
    extends UserImportFromJellyfinPostRequest {
  @override
  final BuiltList<String>? jellyfinUserIds;

  factory _$UserImportFromJellyfinPostRequest(
          [void Function(UserImportFromJellyfinPostRequestBuilder)? updates]) =>
      (UserImportFromJellyfinPostRequestBuilder()..update(updates))._build();

  _$UserImportFromJellyfinPostRequest._({this.jellyfinUserIds}) : super._();
  @override
  UserImportFromJellyfinPostRequest rebuild(
          void Function(UserImportFromJellyfinPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserImportFromJellyfinPostRequestBuilder toBuilder() =>
      UserImportFromJellyfinPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserImportFromJellyfinPostRequest &&
        jellyfinUserIds == other.jellyfinUserIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jellyfinUserIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserImportFromJellyfinPostRequest')
          ..add('jellyfinUserIds', jellyfinUserIds))
        .toString();
  }
}

class UserImportFromJellyfinPostRequestBuilder
    implements
        Builder<UserImportFromJellyfinPostRequest,
            UserImportFromJellyfinPostRequestBuilder> {
  _$UserImportFromJellyfinPostRequest? _$v;

  ListBuilder<String>? _jellyfinUserIds;
  ListBuilder<String> get jellyfinUserIds =>
      _$this._jellyfinUserIds ??= ListBuilder<String>();
  set jellyfinUserIds(ListBuilder<String>? jellyfinUserIds) =>
      _$this._jellyfinUserIds = jellyfinUserIds;

  UserImportFromJellyfinPostRequestBuilder() {
    UserImportFromJellyfinPostRequest._defaults(this);
  }

  UserImportFromJellyfinPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jellyfinUserIds = $v.jellyfinUserIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserImportFromJellyfinPostRequest other) {
    _$v = other as _$UserImportFromJellyfinPostRequest;
  }

  @override
  void update(
      void Function(UserImportFromJellyfinPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserImportFromJellyfinPostRequest build() => _build();

  _$UserImportFromJellyfinPostRequest _build() {
    _$UserImportFromJellyfinPostRequest _$result;
    try {
      _$result = _$v ??
          _$UserImportFromJellyfinPostRequest._(
            jellyfinUserIds: _jellyfinUserIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'jellyfinUserIds';
        _jellyfinUserIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserImportFromJellyfinPostRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

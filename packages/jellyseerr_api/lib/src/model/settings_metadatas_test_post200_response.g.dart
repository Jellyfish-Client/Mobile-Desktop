// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_metadatas_test_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsMetadatasTestPost200Response
    extends SettingsMetadatasTestPost200Response {
  @override
  final String? message;

  factory _$SettingsMetadatasTestPost200Response(
          [void Function(SettingsMetadatasTestPost200ResponseBuilder)?
              updates]) =>
      (SettingsMetadatasTestPost200ResponseBuilder()..update(updates))._build();

  _$SettingsMetadatasTestPost200Response._({this.message}) : super._();
  @override
  SettingsMetadatasTestPost200Response rebuild(
          void Function(SettingsMetadatasTestPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsMetadatasTestPost200ResponseBuilder toBuilder() =>
      SettingsMetadatasTestPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsMetadatasTestPost200Response &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SettingsMetadatasTestPost200Response')
          ..add('message', message))
        .toString();
  }
}

class SettingsMetadatasTestPost200ResponseBuilder
    implements
        Builder<SettingsMetadatasTestPost200Response,
            SettingsMetadatasTestPost200ResponseBuilder> {
  _$SettingsMetadatasTestPost200Response? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  SettingsMetadatasTestPost200ResponseBuilder() {
    SettingsMetadatasTestPost200Response._defaults(this);
  }

  SettingsMetadatasTestPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsMetadatasTestPost200Response other) {
    _$v = other as _$SettingsMetadatasTestPost200Response;
  }

  @override
  void update(
      void Function(SettingsMetadatasTestPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SettingsMetadatasTestPost200Response build() => _build();

  _$SettingsMetadatasTestPost200Response _build() {
    final _$result = _$v ??
        _$SettingsMetadatasTestPost200Response._(
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
